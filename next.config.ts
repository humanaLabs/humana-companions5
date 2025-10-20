import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  experimental: {
    ppr: true,
  },
  images: {
    remotePatterns: [
      {
        hostname: "avatar.vercel.sh",
      },
      {
        protocol: "https",
        hostname: "**.public.blob.vercel-storage.com",
      },
    ],
  },
  webpack: (config) => {
    // Alias Electron imports para stubs no build web (Vercel)
    // Isso evita erros "Module not found" quando componentes React importam código Electron
    config.resolve.alias = {
      ...config.resolve.alias,
      "@/electron/runtime/detection": "@/lib/electron-stub",
      "@/electron/runtime/electron-client": "@/lib/electron-stub",
      "@/electron/runtime/computer-use-client": "@/lib/electron-stub",
      "@/electron/runtime/mcp-client": "@/lib/electron-stub",
    };
    return config;
  },
};

export default nextConfig;
