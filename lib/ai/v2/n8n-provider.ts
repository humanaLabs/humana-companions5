import type {
  LanguageModelV1,
  LanguageModelV1CallOptions,
  LanguageModelV1CallWarning,
  LanguageModelV1FinishReason,
  LanguageModelV1StreamPart,
} from "ai";

const N8N_WEBHOOK_URL = "https://n8n.humana.ai/webhook/chat/completions";

export type N8nLanguageModelConfig = {
  modelId?: string;
  defaultModel?: string;
};

// Helper para converter tools do AI SDK para formato OpenAI
function convertToolsToOpenAIFormat(tools?: Record<string, any>) {
  if (!tools) {
    return;
  }

  return Object.entries(tools).map(([name, tool]) => ({
    type: "function",
    function: {
      name,
      description: tool.description || "",
      parameters: tool.parameters || {},
    },
  }));
}

export function createN8nLanguageModel(
  config: N8nLanguageModelConfig = {}
): LanguageModelV1 {
  const modelId = config.modelId || config.defaultModel || "gpt-4o-mini";

  return {
    specificationVersion: "v2",
    provider: "n8n",
    modelId,
    defaultObjectGenerationMode: "json",
    supportsImageUrls: false,
    supportsStructuredOutputs: false,

    async doGenerate(options: LanguageModelV1CallOptions) {
      const messages = options.prompt.map((msg) => {
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
          content: content || "",
        };
      });

      const tools = convertToolsToOpenAIFormat(options.tools);

      const response = await fetch(N8N_WEBHOOK_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: modelId,
          stream: false,
          messages,
          tools,
        }),
      });

      if (!response.ok) {
        throw new Error(`N8n API error: ${response.status}`);
      }

      const data = await response.json();
      const content = data.choices?.[0]?.message?.content || "";
      const toolCalls = data.choices?.[0]?.message?.tool_calls;

      // Se houver tool calls, converter para formato v2
      const responseContent: any[] = [];

      if (content) {
        responseContent.push({ type: "text", text: content });
      }

      if (toolCalls && Array.isArray(toolCalls)) {
        for (const toolCall of toolCalls) {
          responseContent.push({
            type: "tool-call",
            toolCallId: toolCall.id,
            toolName: toolCall.function.name,
            args: JSON.parse(toolCall.function.arguments || "{}"),
          });
        }
      }

      return {
        content:
          responseContent.length > 0
            ? responseContent
            : [{ type: "text", text: content }],
        finishReason: "stop" as LanguageModelV1FinishReason,
        usage: {
          inputTokens: data.usage?.prompt_tokens || 0,
          outputTokens: data.usage?.completion_tokens || 0,
          totalTokens:
            (data.usage?.prompt_tokens || 0) +
            (data.usage?.completion_tokens || 0),
        },
        rawCall: { rawPrompt: messages, rawSettings: {} },
        warnings: [] as LanguageModelV1CallWarning[],
      };
    },

    async doStream(options: LanguageModelV1CallOptions) {
      console.log("[N8N Provider] doStream called");
      const messages = options.prompt.map((msg) => {
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
          content: content || "",
        };
      });

      const tools = convertToolsToOpenAIFormat(options.tools);

      console.log("[N8N Provider] Calling n8n with messages:", messages.length);
      console.log(
        "[N8N Provider] Tools:",
        tools ? `${tools.length} tools` : "no tools"
      );

      const response = await fetch(N8N_WEBHOOK_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: modelId,
          stream: true,
          messages,
          tools,
        }),
      });

      if (!response.ok) {
        throw new Error(`N8n API error: ${response.status}`);
      }

      if (!response.body) {
        throw new Error("Response body is null");
      }

      const reader = response.body.getReader();
      const decoder = new TextDecoder();
      let buffer = "";

      return {
        stream: new ReadableStream<LanguageModelV1StreamPart>({
          async start(controller) {
            try {
              // Acumula tool calls que vêm fragmentados
              const toolCallsBuffer: Record<number, any> = {};

              while (true) {
                const { done, value } = await reader.read();

                if (done) {
                  break;
                }

                buffer += decoder.decode(value, { stream: true });
                const lines = buffer.split("\n");
                buffer = lines.pop() || "";

                for (const line of lines) {
                  const trimmedLine = line.trim();

                  if (!trimmedLine) {
                    continue;
                  }

                  if (trimmedLine === "data: [DONE]") {
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

                      // Processar content (texto)
                      let content = delta?.content;

                      if (!content && typeof data.content === "string") {
                        content = data.content;
                      }

                      if (!content && typeof data.output === "string") {
                        content = data.output;
                      }

                      if (content) {
                        controller.enqueue({
                          type: "text-delta" as const,
                          textDelta: content,
                        });
                        console.log(
                          "[N8N Provider] Enqueued text-delta:",
                          content.substring(0, 50)
                        );
                      }

                      // Processar tool calls (podem vir fragmentados)
                      if (delta?.tool_calls) {
                        for (const toolCall of delta.tool_calls) {
                          const index = toolCall.index || 0;

                          if (!toolCallsBuffer[index]) {
                            toolCallsBuffer[index] = {
                              id: toolCall.id || "",
                              type: "function",
                              function: {
                                name: toolCall.function?.name || "",
                                arguments: "",
                              },
                            };
                          }

                          // Acumula os fragmentos
                          if (toolCall.id) {
                            toolCallsBuffer[index].id = toolCall.id;
                          }
                          if (toolCall.function?.name) {
                            toolCallsBuffer[index].function.name =
                              toolCall.function.name;
                          }
                          if (toolCall.function?.arguments) {
                            toolCallsBuffer[index].function.arguments +=
                              toolCall.function.arguments;
                          }
                        }
                      }
                    } catch (e) {
                      console.error("[N8N Provider] Error parsing SSE:", e);
                    }
                  }
                }
              }

              // Ao final do stream, emitir tool calls completos
              for (const toolCall of Object.values(toolCallsBuffer)) {
                if (toolCall.id && toolCall.function.name) {
                  console.log(
                    "[N8N Provider] Tool call:",
                    toolCall.function.name
                  );
                  controller.enqueue({
                    type: "tool-call" as const,
                    toolCallId: toolCall.id,
                    toolName: toolCall.function.name,
                    args: JSON.parse(toolCall.function.arguments || "{}"),
                  });
                }
              }

              controller.enqueue({
                type: "finish",
                finishReason: "stop",
                usage: {
                  inputTokens: 0,
                  outputTokens: 0,
                  totalTokens: 0,
                },
              });
            } catch (error) {
              console.error("[N8N Provider] Stream error:", error);
              controller.error(error);
            } finally {
              controller.close();
            }
          },
        }),
        rawCall: { rawPrompt: messages, rawSettings: {} },
        warnings: [] as LanguageModelV1CallWarning[],
      };
    },
  };
}
