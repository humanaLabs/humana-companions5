import { createUIMessageStream, JsonToSseTransformStream } from "ai";
import { auth, type UserType } from "@/app/(auth)/auth";
import type { VisibilityType } from "@/components/visibility-selector";
import { entitlementsByUserType } from "@/lib/ai/entitlements";
import type { ChatModel } from "@/lib/ai/v2/models";
import {
  deleteChatById,
  getChatById,
  getMessageCountByUserId,
  saveChat,
  saveMessages,
} from "@/lib/db/queries";
import { ChatSDKError } from "@/lib/errors";
import type { ChatMessage } from "@/lib/types";
import { generateUUID } from "@/lib/utils";
import { generateTitleFromUserMessage } from "../../../actions";
import { type PostRequestBody, postRequestBodySchema } from "./schema";

export const maxDuration = 60;

// Configuração do webhook n8n
const N8N_WEBHOOK_URL = "https://n8n.humana.ai/webhook/chat";

// Função auxiliar para extrair texto da mensagem
function extractMessageText(message: ChatMessage): string {
  if (message.parts && message.parts.length > 0) {
    const textPart = message.parts.find((part) => part.type === "text");
    if (textPart && "text" in textPart) {
      return textPart.text;
    }
  }
  return "";
}

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
      selectedVisibilityType,
    }: {
      id: string;
      message: ChatMessage;
      selectedChatModel?: ChatModel["id"];
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

    // Extrai o texto da mensagem do usuário
    const userMessageText = extractMessageText(message);

    if (!userMessageText) {
      return new ChatSDKError("bad_request:api").toResponse();
    }

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

    // Chama o webhook do n8n
    console.log("Enviando mensagem para n8n:", {
      text: userMessageText,
      sessionId: id,
    });

    const n8nResponse = await fetch(N8N_WEBHOOK_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        text: userMessageText,
        sessionId: id,
      }),
    });

    if (!n8nResponse.ok) {
      const errorText = await n8nResponse.text();
      console.error("Erro na resposta do n8n:", {
        status: n8nResponse.status,
        statusText: n8nResponse.statusText,
        body: errorText,
      });
      throw new Error(`n8n webhook error: ${n8nResponse.status}`);
    }

    const n8nData = await n8nResponse.json();
    console.log("Resposta do n8n:", n8nData);

    // Extrai o texto da resposta do n8n
    const assistantResponseText =
      typeof n8nData === "string"
        ? n8nData
        : n8nData.output ||
          n8nData.response ||
          n8nData.text ||
          JSON.stringify(n8nData);

    // Cria stream para enviar a resposta
    const assistantMessageId = generateUUID();
    const stream = createUIMessageStream({
      execute: async ({ writer }) => {
        // Inicia a mensagem do assistente
        writer.write({
          type: "start",
          messageId: assistantMessageId,
        });

        // Inicia o texto
        writer.write({
          type: "text-start",
          id: assistantMessageId,
        });

        // Simula streaming da resposta palavra por palavra
        const words = assistantResponseText.split(" ");

        for (const word of words) {
          writer.write({
            type: "text-delta",
            delta: `${word} `,
            id: assistantMessageId,
          });
          // Pequeno delay para simular streaming
          await new Promise((resolve) => setTimeout(resolve, 30));
        }

        // Finaliza o texto
        writer.write({
          type: "text-end",
          id: assistantMessageId,
        });

        // Finaliza a mensagem
        writer.write({
          type: "finish",
        });
      },
      generateId: generateUUID,
      onFinish: async ({ messages }) => {
        // Salva as mensagens geradas
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

  const chat = await getChatById({ id });

  if (chat?.userId !== session.user.id) {
    return new ChatSDKError("forbidden:chat").toResponse();
  }

  const deletedChat = await deleteChatById({ id });

  return Response.json(deletedChat, { status: 200 });
}
