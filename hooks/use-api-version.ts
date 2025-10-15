"use client";

import { usePathname } from "next/navigation";
import { CHAT_VERSION } from "@/lib/constants";

export function useApiVersion() {
  const pathname = usePathname();

  // Check URL first (manual override)
  if (pathname.startsWith("/v5")) {
    return "v5";
  }
  if (pathname.startsWith("/v4")) {
    return "v4";
  }
  if (pathname.startsWith("/v3")) {
    return "v3";
  }
  if (pathname.startsWith("/v2")) {
    return "v2";
  }

  // If no version in URL, use environment variable
  // This allows HUMANA_DEFAULT_CHAT_VERSION to control the default
  return CHAT_VERSION;
}

export function useApiUrl(endpoint: string) {
  const version = useApiVersion();
  return `/api/${version}${endpoint}`;
}
