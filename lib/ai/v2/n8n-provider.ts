import type { LanguageModel } from "ai";

const N8N_WEBHOOK_URL = "https://n8n.humana.ai/webhook/chat/completions2";

export type N8nLanguageModelConfig = {
  modelId?: string;
  defaultModel?: string;
};

// Helper para converter tools do AI SDK para formato OpenAI
function convertToolsToOpenAIFormat(tools?: any) {
  if (!tools || !Array.isArray(tools)) {
    return;
  }

  return tools.map((tool) => {
    console.log(`[N8N Provider] Converting tool: ${tool.name}`, {
      hasName: !!tool.name,
      hasDescription: !!tool.description,
      hasInputSchema: !!tool.inputSchema,
    });

    // AI SDK v5 já fornece:
    // - tool.name: string
    // - tool.description: string
    // - tool.inputSchema: JSON Schema completo

    let parameters = tool.inputSchema || { type: "object", properties: {} };

    // OpenAI NÃO aceita anyOf/oneOf no root do parameters
    // Precisamos transformar em um único objeto com todas as propriedades
    if (parameters.anyOf || parameters.oneOf) {
      const variants = parameters.anyOf || parameters.oneOf;

      // Mesclar todas as properties de todas as variantes
      const mergedProperties: Record<string, any> = {};
      const allRequired = new Set<string>();

      for (const variant of variants) {
        if (variant.properties) {
          Object.assign(mergedProperties, variant.properties);
        }
        // Apenas marca como required se TODAS as variantes requerem
        if (variant.required) {
          for (const req of variant.required) {
            allRequired.add(req);
          }
        }
      }

      parameters = {
        type: "object",
        properties: mergedProperties,
        // Não colocar required se não houver campos requeridos em TODAS variantes
        ...(allRequired.size > 0 ? {} : {}),
      };
    }

    // Remover $schema que pode causar problemas
    const { $schema: _$schema, ...cleanParameters } = parameters;

    // Lógica especial para getWeather: marcar "city" como required
    // Isso garante que o OpenAI sempre envie pelo menos o campo "city"
    // (embora o Zod schema aceite também latitude/longitude)
    if (tool.name === "getWeather") {
      cleanParameters.required = ["city"];
      console.log(
        "[N8N Provider] 🔥🔥🔥 APPLIED SPECIAL LOGIC FOR GETWEATHER: marked 'city' as required"
      );
      console.log(
        "[N8N Provider] getWeather parameters AFTER modification:",
        JSON.stringify(cleanParameters, null, 2)
      );
    }

    const toolDef = {
      type: "function",
      function: {
        name: tool.name,
        description: tool.description || "",
        parameters: cleanParameters,
      },
    };

    console.log(
      `[N8N Provider] Final tool definition for ${tool.name}:`,
      JSON.stringify(toolDef, null, 2)
    );

    return toolDef;
  });
}

export function createN8nLanguageModel(
  config: N8nLanguageModelConfig = {}
): LanguageModel {
  const modelId = config.modelId || config.defaultModel || "gpt-4o-mini";

  return {
    specificationVersion: "v2",
    provider: "n8n",
    modelId,
    defaultObjectGenerationMode: "json",
    supportedUrls: [],
    supportsImageUrls: false,
    supportsStructuredOutputs: false,

    doGenerate: async (options: any) => {
      const messages = options.prompt.map((msg: any) => {
        let content = "";

        if (Array.isArray(msg.content)) {
          content = msg.content
            .map((part: any) => {
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
          console.log(
            "[N8N Provider] Tool call in doGenerate:",
            toolCall.function.name
          );
          responseContent.push({
            type: "tool-call",
            toolCallId: toolCall.id,
            toolName: toolCall.function.name,
            args: JSON.parse(toolCall.function.arguments || "{}"),
          });
        }
      }

      // ✅ CRUCIAL: finishReason deve ser "tool-calls" quando houver tool calls!
      const finishReason =
        toolCalls && toolCalls.length > 0 ? "tool-calls" : "stop";

      return {
        content:
          responseContent.length > 0
            ? responseContent
            : [{ type: "text", text: content }],
        finishReason: finishReason as any,
        usage: {
          inputTokens: data.usage?.prompt_tokens || 0,
          outputTokens: data.usage?.completion_tokens || 0,
          totalTokens:
            (data.usage?.prompt_tokens || 0) +
            (data.usage?.completion_tokens || 0),
        },
        rawCall: { rawPrompt: messages, rawSettings: {} },
        warnings: [],
      };
    },

    doStream: async (options: any) => {
      console.log("[N8N Provider] doStream called");
      console.log(
        "[N8N Provider] Raw options.tools:",
        JSON.stringify(options.tools, null, 2)
      );

      const messages = options.prompt.map((msg: any) => {
        let content = "";

        if (Array.isArray(msg.content)) {
          content = msg.content
            .map((part: any) => {
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

      // 🔍 DEBUG: Ver exatamente o que está sendo enviado
      const requestBody = {
        model: modelId,
        stream: true,
        messages,
        tools,
      };
      console.log(
        "[N8N Provider] Request body tools:",
        JSON.stringify(requestBody.tools, null, 2)
      );

      console.log("[N8N Provider] 📤 Sending request to n8n...");
      const response = await fetch(N8N_WEBHOOK_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(requestBody),
      });

      console.log(
        "[N8N Provider] ✅ Response received, status:",
        response.status
      );

      if (!response.ok) {
        throw new Error(`N8n API error: ${response.status}`);
      }

      if (!response.body) {
        throw new Error("Response body is null");
      }

      const reader = response.body.getReader();
      const decoder = new TextDecoder();
      let buffer = "";

      const stepId = `step-${Date.now()}`;
      let hasStartedText = false;
      let openaiFinishReason: string | null = null;

      return {
        stream: new ReadableStream({
          async start(controller) {
            console.log(
              "[N8N Provider] 🆕 Starting NEW stream for stepId:",
              stepId
            );
            try {
              // Acumula tool calls que vêm fragmentados
              const toolCallsBuffer: Record<number, any> = {};

              while (true) {
                const { done, value } = await reader.read();

                if (done) {
                  console.log(
                    "[N8N Provider] ✅ Stream done - reader finished"
                  );
                  break;
                }

                const chunk = decoder.decode(value, { stream: true });
                console.log(
                  "[N8N Provider] Raw chunk received:",
                  chunk.substring(0, 200)
                );

                buffer += chunk;
                const lines = buffer.split("\n");
                buffer = lines.pop() || "";

                for (const line of lines) {
                  const trimmedLine = line.trim();

                  if (!trimmedLine) {
                    continue;
                  }

                  console.log(
                    "[N8N Provider] Processing line:",
                    trimmedLine.substring(0, 150)
                  );

                  if (trimmedLine === "data: [DONE]") {
                    console.log("[N8N Provider] Received [DONE]");
                    continue;
                  }

                  if (trimmedLine.startsWith("data:")) {
                    const jsonStr = trimmedLine.slice(5).trim();

                    if (!jsonStr) {
                      continue;
                    }

                    console.log(
                      "[N8N Provider] Attempting to parse JSON:",
                      jsonStr.substring(0, 200)
                    );

                    try {
                      const data = JSON.parse(jsonStr);
                      const choice = data.choices?.[0];
                      const delta = choice?.delta;

                      // Capturar finish_reason do OpenAI (vem em choices[0].finish_reason, não no delta)
                      if (choice?.finish_reason) {
                        openaiFinishReason = choice.finish_reason;
                        console.log(
                          "[N8N Provider] OpenAI finish_reason:",
                          openaiFinishReason
                        );
                      }

                      // 🔍 DEBUG: Ver TUDO que o n8n está retornando
                      console.log(
                        "[N8N Provider] Full SSE chunk:",
                        JSON.stringify(data).substring(0, 500)
                      );

                      // Processar content (texto)
                      let content = delta?.content;

                      if (!content && typeof data.content === "string") {
                        content = data.content;
                      }

                      if (!content && typeof data.output === "string") {
                        content = data.output;
                      }

                      if (content) {
                        // Enviar text-start na primeira vez
                        if (!hasStartedText) {
                          controller.enqueue({
                            type: "text-start",
                            id: stepId,
                          });
                          hasStartedText = true;
                          console.log("[N8N Provider] Enqueued text-start");
                        }

                        // Enviar text-delta com id e delta (formato AI SDK v5)
                        controller.enqueue({
                          type: "text-delta",
                          id: stepId,
                          delta: content,
                        });
                        console.log(
                          "[N8N Provider] Enqueued text-delta:",
                          content.substring(0, 50)
                        );
                      }

                      // Processar tool calls (podem vir fragmentados)
                      if (delta?.tool_calls) {
                        console.log(
                          "[N8N Provider] Received tool_calls in delta:",
                          JSON.stringify(delta.tool_calls)
                        );

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
                            console.log(
                              "[N8N Provider] Started buffering tool call at index",
                              index
                            );
                          }

                          // Acumula os fragmentos
                          if (toolCall.id) {
                            toolCallsBuffer[index].id = toolCall.id;
                          }
                          if (toolCall.function?.name) {
                            toolCallsBuffer[index].function.name =
                              toolCall.function.name;
                            console.log(
                              "[N8N Provider] Tool name:",
                              toolCall.function.name
                            );
                          }
                          if (toolCall.function?.arguments) {
                            toolCallsBuffer[index].function.arguments +=
                              toolCall.function.arguments;
                            console.log(
                              "[N8N Provider] Tool args fragment:",
                              toolCall.function.arguments
                            );
                          }
                        }
                      }
                    } catch (e) {
                      console.error("[N8N Provider] Error parsing SSE:", e);
                    }
                  }
                }
              }

              // Finalizar texto se foi iniciado
              if (hasStartedText) {
                controller.enqueue({
                  type: "text-finish",
                  id: stepId,
                });
                console.log("[N8N Provider] Enqueued text-finish");
              }

              // Ao final do stream, emitir tool calls completos
              const hasToolCalls = Object.keys(toolCallsBuffer).length > 0;

              for (const toolCall of Object.values(toolCallsBuffer)) {
                if (toolCall.id && toolCall.function.name) {
                  console.log(
                    "[N8N Provider] Tool call detected:",
                    toolCall.function.name,
                    "with args:",
                    toolCall.function.arguments
                  );
                  controller.enqueue({
                    type: "tool-call",
                    toolCallId: toolCall.id,
                    toolName: toolCall.function.name,
                    args: JSON.parse(toolCall.function.arguments || "{}"),
                  });
                }
              }

              // ✅ CRUCIAL: usar o finish_reason do OpenAI
              // OpenAI retorna "tool_calls" mas o SDK espera "tool-calls" (com hífen)
              let finishReason: string;
              if (openaiFinishReason === "tool_calls") {
                finishReason = "tool-calls";
              } else if (openaiFinishReason) {
                finishReason = openaiFinishReason;
              } else {
                // Fallback: deduzir do conteúdo
                finishReason = hasToolCalls ? "tool-calls" : "stop";
              }

              console.log(
                "[N8N Provider] Finishing with reason:",
                finishReason,
                "(from OpenAI:",
                openaiFinishReason,
                ")"
              );

              controller.enqueue({
                type: "finish",
                finishReason: finishReason as any,
                usage: {
                  inputTokens: 0,
                  outputTokens: 0,
                  totalTokens: 0,
                },
              });
            } catch (error) {
              console.error("[N8N Provider] ❌ Stream error:", error);
              controller.error(error);
            } finally {
              console.log(
                "[N8N Provider] 🔒 Closing controller for stepId:",
                stepId
              );
              controller.close();
              console.log("[N8N Provider] ✅ Controller closed successfully");
            }
          },
        }),
        rawCall: { rawPrompt: messages, rawSettings: {} },
        warnings: [],
      };
    },
  } as unknown as LanguageModel;
}
