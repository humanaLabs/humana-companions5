// Shared provider for artifacts (used by all versions)
// biome-ignore lint/performance/noBarrelFile: Intentional re-export to share common provider across versions
export { myProvider } from "./v1/providers";
