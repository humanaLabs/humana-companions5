// Shared prompts for artifacts (used by all versions)
// biome-ignore lint/performance/noBarrelFile: Intentional re-export to share common prompts across versions
export {
  artifactsPrompt,
  codePrompt,
  getRequestPromptFromHints,
  type RequestHints,
  regularPrompt,
  sheetPrompt,
  systemPrompt,
  updateDocumentPrompt,
} from "./v1/prompts";
