"use client";

import Image from "next/image";
import { useRouter } from "next/navigation";
import type { User } from "next-auth";
import { signOut, useSession } from "next-auth/react";
import { useTheme } from "next-themes";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { guestRegex } from "@/lib/constants";
import { toast } from "./toast";

export function SidebarUserNav({ user }: { user: User }) {
  const router = useRouter();
  const { data, status } = useSession();
  const { setTheme, resolvedTheme } = useTheme();

  const isGuest = guestRegex.test(data?.user?.email ?? "");

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        {status === "loading" ? (
          <Button
            className="size-8 border-0 p-0 outline-none ring-0 focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent"
            variant="ghost"
          >
            <div className="size-6 animate-pulse rounded-full bg-zinc-500/30" />
          </Button>
        ) : (
          <Button
            className="size-8 border-0 p-0 outline-none ring-0 focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent"
            data-testid="user-nav-button"
            variant="ghost"
          >
            <Image
              alt={user.email ?? "User Avatar"}
              className="rounded-full"
              height={24}
              src={`https://avatar.vercel.sh/${user.email}`}
              width={24}
            />
          </Button>
        )}
      </DropdownMenuTrigger>
      <DropdownMenuContent
        align="end"
        className="w-[200px]"
        data-testid="user-nav-menu"
      >
        <DropdownMenuItem
          className="cursor-pointer"
          data-testid="user-nav-item-theme"
          onSelect={() => setTheme(resolvedTheme === "dark" ? "light" : "dark")}
        >
          {`Toggle ${resolvedTheme === "light" ? "dark" : "light"} mode`}
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem asChild data-testid="user-nav-item-auth">
          <button
            className="w-full cursor-pointer"
            onClick={() => {
              if (status === "loading") {
                toast({
                  type: "error",
                  description:
                    "Checking authentication status, please try again!",
                });

                return;
              }

              if (isGuest) {
                router.push("/login");
              } else {
                signOut({
                  redirectTo: "/",
                });
              }
            }}
            type="button"
          >
            {isGuest ? "Login to your account" : "Sign out"}
          </button>
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
