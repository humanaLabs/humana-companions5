import { geolocation } from "@vercel/functions";
import {
  convertToModelMessages,
  createUIMessageStream,
  JsonToSseTransformStream,
  streamText,
} from "ai";
import { auth, type UserType } from "@/app/(auth)/auth";
import type { VisibilityType } from "@/components/visibility-selector";
import { entitlementsByUserType } from "@/lib/ai/entitlements";
import type { ChatModel } from "@/lib/ai/v2/models";
import { type RequestHints, systemPrompt } from "@/lib/ai/v2/prompts";
import { myProvider } from "@/lib/ai/v2/providers";
import { createDocument } from "@/lib/ai/v2/tools/create-document";
import { getWeather } from "@/lib/ai/v2/tools/get-weather";
import { requestSuggestions } from "@/lib/ai/v2/tools/request-suggestions";
import { updateDocument } from "@/lib/ai/v2/tools/update-document";
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

export async function POST(request: Request) {
  const requestId = `req-${Date.now()}`;
  console.log(`[Chat API V2] 🆕 NEW REQUEST ${requestId} received`);

  let requestBody: PostRequestBody;

  try {
    const json = await request.json();
    requestBody = postRequestBodySchema.parse(json);
    console.log(`[Chat API V2] ${requestId} - Request body parsed`);
  } catch (_) {
    console.log(`[Chat API V2] ${requestId} - ❌ Bad request`);
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

    console.log(`[Chat API V2] ${requestId} - Chat ID: ${id}`);
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
      execute: ({ writer: dataStream }) => {
        console.log("[Chat API V2] Using native streamText with n8n provider");

        const result = streamText({
          model: myProvider.languageModel(selectedChatModel),
          system: systemPrompt({
            selectedChatModel,
            requestHints,
          }),
          messages: convertToModelMessages(uiMessages),
          experimental_activeTools:
            selectedChatModel === "chat-model-reasoning"
              ? []
              : [
                  "getWeather",
                  "createDocument",
                  "updateDocument",
                  "requestSuggestions",
                ],
          tools: {
            getWeather,
            createDocument: createDocument({
              session,
              dataStream,
            }),
            updateDocument: updateDocument({
              session,
              dataStream,
            }),
            requestSuggestions: requestSuggestions({
              session,
              dataStream,
            }),
          },
          onFinish: ({ text, toolCalls, finishReason, toolResults }) => {
            console.log("[Chat API V2] ✅ Generation finished!");
            console.log("[Chat API V2] - Text:", text?.substring(0, 100));
            console.log("[Chat API V2] - Tool calls:", toolCalls?.length || 0);
            if (toolCalls && toolCalls.length > 0) {
              console.log(
                "[Chat API V2] - Tool calls details:",
                JSON.stringify(toolCalls, null, 2)
              );
            }
            console.log(
              "[Chat API V2] - Tool results:",
              toolResults?.length || 0
            );
            if (toolResults && toolResults.length > 0) {
              console.log(
                "[Chat API V2] - Tool results details:",
                JSON.stringify(toolResults, null, 2)
              );
            }
            console.log("[Chat API V2] - Finish reason:", finishReason);
          },
        });

        console.log("[Chat API V2] Consuming stream from n8n provider...");
        result.consumeStream();

        console.log("[Chat API V2] Merging UI stream...");

        const uiStream = result.toUIMessageStream({
          sendReasoning: true,
        });

        dataStream.merge(uiStream);
        console.log("[Chat API V2] ✅ UI stream merged into dataStream");
      },
      generateId: generateUUID,
      onFinish: async ({ messages }) => {
        console.log(
          "[Chat API V2] 🎯 onFinish callback called - Saving",
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

    console.log("[Chat API V2] 📤 Returning SSE stream to client");

    const response = new Response(
      stream.pipeThrough(new JsonToSseTransformStream())
    );
    console.log("[Chat API V2] ✅ Response created successfully");
    return response;
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
