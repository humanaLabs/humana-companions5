export {};

declare global {
  // biome-ignore lint/nursery/useConsistentTypeDefinitions: Required for global Window
  interface Window {
    env: {
      isElectron: boolean;
      platform: string;
      version: string;
    };

    mcp: {
      listTools: () => Promise<any>;
      callTool: (name: string, args?: any) => Promise<any>;
    };

    computerUse: {
      listTools: () => Promise<any>;
      callTool: (name: string, args?: any) => Promise<any>;
    };
  }
}
