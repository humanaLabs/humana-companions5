import { customProvider } from "ai";
import { isTestEnvironment } from "../../constants";
import { createN8nLanguageModel } from "./n8n-provider";

export const myProvider = isTestEnvironment
  ? (() => {
      const {
        artifactModel,
        chatModel,
        reasoningModel,
        titleModel,
      } = require("../models.mock");
      return customProvider({
        languageModels: {
          "chat-model": chatModel,
          "chat-model-reasoning": reasoningModel,
          "title-model": titleModel,
          "artifact-model": artifactModel,
        },
      });
    })()
  : customProvider({
      languageModels: {
        "chat-model": createN8nLanguageModel({
          modelId: "gpt-4o-mini",
        }),
        "chat-model-reasoning": createN8nLanguageModel({
          modelId: "gpt-4o-mini",
        }),
        "title-model": createN8nLanguageModel({
          modelId: "gpt-4o-mini",
        }),
        "artifact-model": createN8nLanguageModel({
          modelId: "gpt-4o-mini",
        }),
      },
    });
