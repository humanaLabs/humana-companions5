"use client";

import { usePathname } from "next/navigation";

export function useApiVersion() {
  const pathname = usePathname();

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
  return "v1";
}

export function useApiUrl(endpoint: string) {
  const version = useApiVersion();
  return `/api/${version}${endpoint}`;
}
