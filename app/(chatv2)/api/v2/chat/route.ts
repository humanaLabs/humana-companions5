import { geolocation } from "@vercel/functions";
import {
  convertToModelMessages,
  createUIMessageStream,
  JsonToSseTransformStream,
} from "ai";
import { auth, type UserType } from "@/app/(auth)/auth";
import type { VisibilityType } from "@/components/visibility-selector";
import { entitlementsByUserType } from "@/lib/ai/entitlements";
import type { ChatModel } from "@/lib/ai/v2/models";
import { type RequestHints, systemPrompt } from "@/lib/ai/v2/prompts";
import {
  deleteChatById,
  getChatById,
  getMessageCountByUserId,
  getMessagesByChatId,
  saveChat,
  saveMessages,
} from "@/lib/db/queries";
import { ChatSDKError } from "@/lib/errors";
import type { ChatMessage } from "@/lib/types";
import { convertToUIMessages, generateUUID } from "@/lib/utils";
import { generateTitleFromUserMessage } from "../../../actions";
import { type PostRequestBody, postRequestBodySchema } from "./schema";

export const maxDuration = 60;

const N8N_WEBHOOK_URL = "https://n8n.humana.ai/webhook/chat/completions";

export async function POST(request: Request) {
  let requestBody: PostRequestBody;

  try {
    const json = await request.json();
    requestBody = postRequestBodySchema.parse(json);
  } catch (_) {
    return new ChatSDKError("bad_request:api").toResponse();
  }

  try {
    const {
      id,
      message,
      selectedChatModel,
      selectedVisibilityType,
    }: {
      id: string;
      message: ChatMessage;
      selectedChatModel: ChatModel["id"];
      selectedVisibilityType: VisibilityType;
    } = requestBody;

    const session = await auth();

    if (!session?.user) {
      return new ChatSDKError("unauthorized:chat").toResponse();
    }

    const userType: UserType = session.user.type;

    const messageCount = await getMessageCountByUserId({
      id: session.user.id,
      differenceInHours: 24,
    });

    if (messageCount > entitlementsByUserType[userType].maxMessagesPerDay) {
      return new ChatSDKError("rate_limit:chat").toResponse();
    }

    const chat = await getChatById({ id });

    if (chat) {
      if (chat.userId !== session.user.id) {
        return new ChatSDKError("forbidden:chat").toResponse();
      }
    } else {
      const title = await generateTitleFromUserMessage({
        message,
      });

      await saveChat({
        id,
        userId: session.user.id,
        title,
        visibility: selectedVisibilityType,
      });
    }

    const messagesFromDb = await getMessagesByChatId({ id });
    const uiMessages = [...convertToUIMessages(messagesFromDb), message];

    const { longitude, latitude, city, country } = geolocation(request);

    const requestHints: RequestHints = {
      longitude,
      latitude,
      city,
      country,
    };

    await saveMessages({
      messages: [
        {
          chatId: id,
          id: message.id,
          role: "user",
          parts: message.parts,
          attachments: [],
          createdAt: new Date(),
        },
      ],
    });

    const stream = createUIMessageStream({
      execute: async ({ writer: dataStream }) => {
        const systemPromptText = systemPrompt({
          selectedChatModel,
          requestHints,
        });

        console.log("[Chat API V2] Calling n8n directly");

        // Preparar mensagens
        const n8nMessages = [
          { role: "system", content: systemPromptText },
          ...convertToModelMessages(uiMessages).map((msg) => {
            let content = "";
            if (Array.isArray(msg.content)) {
              content = msg.content
                .map((part) => {
                  if (part.type === "text") {
                    return part.text;
                  }
                  return "";
                })
                .join("\n");
            } else if (typeof msg.content === "string") {
              content = msg.content;
            }
            return {
              role: msg.role,
              content,
            };
          }),
        ];

        // Definir tools em formato OpenAI
        const tools = [
          {
            type: "function",
            function: {
              name: "getWeather",
              description: "Get the current weather at a location",
              parameters: {
                type: "object",
                properties: {
                  latitude: { type: "number" },
                  longitude: { type: "number" },
                },
                required: ["latitude", "longitude"],
              },
            },
          },
        ];

        // Chamar n8n
        const response = await fetch(N8N_WEBHOOK_URL, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: selectedChatModel,
            stream: true,
            messages: n8nMessages,
            tools,
          }),
        });

        if (!response.ok) {
          throw new Error(`N8n API error: ${response.status}`);
        }

        if (!response.body) {
          throw new Error("Response body is null");
        }

        console.log("[Chat API V2] Streaming from n8n...");

        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let buffer = "";
        let fullText = "";

        const textStepId = generateUUID();
        let hasStartedText = false;

        try {
          while (true) {
            const { done, value } = await reader.read();

            if (done) {
              console.log("[Chat API V2] Stream done");
              break;
            }

            buffer += decoder.decode(value, { stream: true });
            const lines = buffer.split("\n");
            buffer = lines.pop() || "";

            for (const line of lines) {
              const trimmedLine = line.trim();

              if (!trimmedLine || trimmedLine === "data: [DONE]") {
                continue;
              }

              if (trimmedLine.startsWith("data:")) {
                const jsonStr = trimmedLine.slice(5).trim();

                if (!jsonStr) {
                  continue;
                }

                try {
                  const data = JSON.parse(jsonStr);
                  const delta = data.choices?.[0]?.delta;

                  // Processar texto
                  let content = delta?.content;

                  if (!content && typeof data.content === "string") {
                    content = data.content;
                  }

                  if (!content && typeof data.output === "string") {
                    content = data.output;
                  }

                  if (content) {
                    console.log("[Chat API V2] Text chunk:", content);
                    fullText += content;

                    // Enviar como parte da mensagem, não annotation
                    if (!hasStartedText) {
                      dataStream.write({
                        type: "text-start",
                        id: textStepId,
                      });
                      hasStartedText = true;
                    }

                    dataStream.write({
                      type: "text-delta",
                      delta: content,
                      id: textStepId,
                    });
                  }

                  // TODO: Processar tool calls
                  if (delta?.tool_calls) {
                    console.log("[Chat API V2] Tool calls:", delta.tool_calls);
                  }
                } catch (e) {
                  console.error("[Chat API V2] Parse error:", e);
                }
              }
            }
          }
        } finally {
          reader.releaseLock();
        }

        // Finalizar texto
        if (hasStartedText) {
          dataStream.write({
            type: "text-end",
            id: textStepId,
          });
        }

        console.log("[Chat API V2] Full text:", fullText);
      },
      generateId: generateUUID,
      onFinish: async ({ messages }) => {
        console.log(
          "[Chat API V2] onFinish - Saving",
          messages.length,
          "messages"
        );

        await saveMessages({
          messages: messages.map((currentMessage) => ({
            id: currentMessage.id,
            role: currentMessage.role,
            parts: currentMessage.parts,
            createdAt: new Date(),
            attachments: [],
            chatId: id,
          })),
        });
      },
      onError: () => {
        return "Oops, ocorreu um erro!";
      },
    });

    console.log("[Chat API V2] Returning stream");

    return new Response(stream.pipeThrough(new JsonToSseTransformStream()));
  } catch (error) {
    const vercelId = request.headers.get("x-vercel-id");

    if (error instanceof ChatSDKError) {
      return error.toResponse();
    }

    // Check for Vercel AI Gateway credit card error
    if (
      error instanceof Error &&
      error.message?.includes(
        "AI Gateway requires a valid credit card on file to service requests"
      )
    ) {
      return new ChatSDKError("bad_request:activate_gateway").toResponse();
    }

    console.error("Unhandled error in chat API:", error, { vercelId });
    return new ChatSDKError("offline:chat").toResponse();
  }
}

export async function DELETE(request: Request) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get("id");

  if (!id) {
    return new ChatSDKError("bad_request:api").toResponse();
  }

  const session = await auth();

  if (!session?.user) {
    return new ChatSDKError("unauthorized:chat").toResponse();
  }

  try {
    const chat = await getChatById({ id });

    if (!chat) {
      return new ChatSDKError("not_found:chat").toResponse();
    }

    if (chat.userId !== session.user.id) {
      return new ChatSDKError("forbidden:chat").toResponse();
    }

    await deleteChatById({ id });

    return new Response("Chat deleted", { status: 200 });
  } catch {
    return new ChatSDKError("not_found:chat").toResponse();
  }
}
