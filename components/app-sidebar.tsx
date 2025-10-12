"use client";

import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import type { User } from "next-auth";
import { useState } from "react";
import { toast } from "sonner";
import { useSWRConfig } from "swr";
import { unstable_serialize } from "swr/infinite";
import { HomeIcon, PlusIcon, TrashIcon } from "@/components/icons";
import {
  getChatHistoryPaginationKey,
  SidebarHistory,
} from "@/components/sidebar-history";
import { Button } from "@/components/ui/button";
import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarMenu,
  useSidebar,
} from "@/components/ui/sidebar";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "./ui/alert-dialog";
import { Tooltip, TooltipContent, TooltipTrigger } from "./ui/tooltip";

export function AppSidebar({ user }: { user: User | undefined }) {
  const router = useRouter();
  const { setOpenMobile, toggleSidebar } = useSidebar();
  const { mutate } = useSWRConfig();
  const [showDeleteAllDialog, setShowDeleteAllDialog] = useState(false);

  const handleDeleteAll = () => {
    const deletePromise = fetch("/api/history", {
      method: "DELETE",
    });

    toast.promise(deletePromise, {
      loading: "Deleting all chats...",
      success: () => {
        mutate(unstable_serialize(getChatHistoryPaginationKey));
        router.push("/");
        setShowDeleteAllDialog(false);
        return "All chats deleted successfully";
      },
      error: "Failed to delete all chats",
    });
  };

  const handleSidebarClick = () => {
    toggleSidebar();
  };

  const handleSidebarAreaClick = (e: React.MouseEvent<HTMLDivElement>) => {
    // Verifica se o clique foi diretamente na área vazia (não em botões)
    const target = e.target as HTMLElement;

    // Ignora cliques em botões e links
    if (target.tagName === "BUTTON" || target.tagName === "A") {
      return;
    }

    // Ignora se clicar dentro de um botão ou link
    if (target.closest("button, a")) {
      return;
    }

    // Se chegou aqui, é área vazia - faz o toggle
    toggleSidebar();
  };

  return (
    <>
      <Sidebar
        className="border-r"
        collapsible="icon"
        onClick={handleSidebarAreaClick}
        side="left"
        variant="sidebar"
      >
        <SidebarHeader>
          <SidebarMenu>
            <div className="flex flex-col items-start gap-2">
              <Tooltip>
                <TooltipTrigger asChild>
                  <button
                    className="flex h-8 w-full cursor-pointer items-center justify-start gap-3 rounded-md border-0 bg-transparent px-2 py-1 outline-none ring-0 hover:bg-muted focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent group-data-[collapsible=icon]:justify-center"
                    onClick={handleSidebarClick}
                    type="button"
                  >
                    <Image
                      alt="Humana AI"
                      className="shrink-0 invert dark:invert-0"
                      height={24}
                      priority
                      src="/images/icone_branco-Humana.png"
                      style={{ width: "auto", height: "24px" }}
                      width={24}
                    />
                    <span className="group-data-[collapsible=icon]:sr-only">
                      Humana AI
                    </span>
                  </button>
                </TooltipTrigger>
                <TooltipContent
                  className="group-data-[collapsible=icon]:block group-data-[state=expanded]:hidden"
                  side="right"
                >
                  Humana AI
                </TooltipContent>
              </Tooltip>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    className="h-8 w-full justify-start border-0 p-2 outline-none ring-0 focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent group-data-[collapsible=icon]:w-8 group-data-[collapsible=icon]:justify-center"
                    onClick={() => {
                      setOpenMobile(false);
                      router.push("/");
                      router.refresh();
                    }}
                    type="button"
                    variant="ghost"
                  >
                    <PlusIcon />
                    <span className="ml-2 group-data-[collapsible=icon]:sr-only">
                      New Chat
                    </span>
                  </Button>
                </TooltipTrigger>
                <TooltipContent
                  className="group-data-[collapsible=icon]:block group-data-[state=expanded]:hidden"
                  side="right"
                >
                  New Chat
                </TooltipContent>
              </Tooltip>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button
                    asChild
                    className="h-8 w-full justify-start border-0 p-2 outline-none ring-0 focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent group-data-[collapsible=icon]:w-8 group-data-[collapsible=icon]:justify-center"
                    type="button"
                    variant="ghost"
                  >
                    <Link href="/" onClick={() => setOpenMobile(false)}>
                      <HomeIcon size={16} />
                      <span className="ml-2 group-data-[collapsible=icon]:sr-only">
                        Home
                      </span>
                    </Link>
                  </Button>
                </TooltipTrigger>
                <TooltipContent
                  className="group-data-[collapsible=icon]:block group-data-[state=expanded]:hidden"
                  side="right"
                >
                  Home
                </TooltipContent>
              </Tooltip>
              {user && (
                <Tooltip>
                  <TooltipTrigger asChild>
                    <Button
                      className="h-8 w-full justify-start border-0 p-2 outline-none ring-0 focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent group-data-[collapsible=icon]:w-8 group-data-[collapsible=icon]:justify-center"
                      onClick={() => setShowDeleteAllDialog(true)}
                      type="button"
                      variant="ghost"
                    >
                      <TrashIcon />
                      <span className="ml-2 group-data-[collapsible=icon]:sr-only">
                        Delete All
                      </span>
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent
                    className="group-data-[collapsible=icon]:block group-data-[state=expanded]:hidden"
                    side="right"
                  >
                    Delete All Chats
                  </TooltipContent>
                </Tooltip>
              )}
            </div>
          </SidebarMenu>
        </SidebarHeader>
        <SidebarContent className="group-data-[collapsible=icon]:hidden">
          <SidebarHistory user={user} />
        </SidebarContent>
      </Sidebar>

      <AlertDialog
        onOpenChange={setShowDeleteAllDialog}
        open={showDeleteAllDialog}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete all chats?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone. This will permanently delete all
              your chats and remove them from our servers.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDeleteAll}>
              Delete All
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
