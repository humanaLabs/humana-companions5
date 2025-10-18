export const isBrowser = typeof window !== "undefined";

export function isElectron(): boolean {
  if (!isBrowser) {
    return false;
  }
  return !!(window as any).env?.isElectron;
}

export function hasMCP(): boolean {
  if (!isBrowser) {
    return false;
  }
  return !!(window as any).mcp;
}

export function hasComputerUse(): boolean {
  if (!isBrowser) {
    return false;
  }
  return !!(window as any).computerUse;
}

export function getPlatform(): string | null {
  if (!isElectron()) {
    return null;
  }
  return (window as any).env?.platform ?? null;
}

export function getElectronVersion(): string | null {
  if (!isElectron()) {
    return null;
  }
  return (window as any).env?.version ?? null;
}
