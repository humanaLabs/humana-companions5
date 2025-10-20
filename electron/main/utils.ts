export function isDevelopment(): boolean {
  return process.env.NODE_ENV === "development";
}

export function npxCmd(): string {
  return process.platform === "win32" ? "npx.cmd" : "npx";
}

export function getStartUrl(): string {
  // Em desenvolvimento, usa localhost
  if (isDevelopment()) {
    return process.env.ELECTRON_START_URL || "http://localhost:3000";
  }

  // Em produção, usa variável de ambiente ou fallback
  return process.env.ELECTRON_START_URL || "https://chat.humana.ai";
}
