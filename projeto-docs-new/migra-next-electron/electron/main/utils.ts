export function isDevelopment(): boolean {
  return process.env.NODE_ENV === "development";
}

export function npxCmd(): string {
  return process.platform === "win32" ? "npx.cmd" : "npx";
}

export function getStartUrl(): string {
  // Em desenvolvimento, tenta localhost primeiro
  // Usa variável de ambiente ou default para localhost:3000
  if (isDevelopment() || !process.env.ELECTRON_START_URL) {
    return process.env.ELECTRON_START_URL || "http://localhost:3000";
  }
  return "https://chat.vercel.ai";
}
