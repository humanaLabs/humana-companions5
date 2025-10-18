// Tipos globais do Electron expostos via contextBridge

export interface ElectronEnv {
  isElectron: boolean;
  platform: NodeJS.Platform;
  version: string;
}

declare global {
  interface Window {
    env?: ElectronEnv;
  }
}

export {};

