"use client";

import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import type { User } from "next-auth";
import {
  BriefcaseIcon,
  GraduationCapIcon,
  PencilEditIcon,
} from "@/components/icons";
import { SidebarHistory } from "@/components/sidebar-history";
import { Button } from "@/components/ui/button";
import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarMenu,
  useSidebar,
} from "@/components/ui/sidebar";
import { useApiVersion } from "@/hooks/use-api-version";
import { Tooltip, TooltipContent, TooltipTrigger } from "./ui/tooltip";

export function AppSidebar({ user }: { user: User | undefined }) {
  const router = useRouter();
  const apiVersion = useApiVersion();
  const { setOpenMobile, toggleSidebar } = useSidebar();

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
                <Button
                  className="h-8 w-full justify-start border-0 p-2 outline-none ring-0 focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent group-data-[collapsible=icon]:w-8"
                  onClick={handleSidebarClick}
                  type="button"
                  variant="ghost"
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
                  <span className="ml-2 group-data-[collapsible=icon]:sr-only">
                    Humana AI
                  </span>
                </Button>
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
                  className="h-8 w-full justify-start border-0 p-2 outline-none ring-0 focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent group-data-[collapsible=icon]:w-8"
                  onClick={() => {
                    setOpenMobile(false);
                    router.push(`/${apiVersion}`);
                    router.refresh();
                  }}
                  type="button"
                  variant="ghost"
                >
                  <PencilEditIcon size={16} />
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
                  className="h-8 w-full justify-start border-0 p-2 outline-none ring-0 focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent group-data-[collapsible=icon]:w-8"
                  type="button"
                  variant="ghost"
                >
                  <Link href="/workspaces" onClick={() => setOpenMobile(false)}>
                    <BriefcaseIcon size={16} />
                    <span className="ml-2 group-data-[collapsible=icon]:sr-only">
                      My Workspaces
                    </span>
                  </Link>
                </Button>
              </TooltipTrigger>
              <TooltipContent
                className="group-data-[collapsible=icon]:block group-data-[state=expanded]:hidden"
                side="right"
              >
                My Workspaces
              </TooltipContent>
            </Tooltip>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  asChild
                  className="h-8 w-full justify-start border-0 p-2 outline-none ring-0 focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-transparent group-data-[collapsible=icon]:w-8"
                  type="button"
                  variant="ghost"
                >
                  <Link
                    href="/learning-hub"
                    onClick={() => setOpenMobile(false)}
                  >
                    <GraduationCapIcon size={16} />
                    <span className="ml-2 group-data-[collapsible=icon]:sr-only">
                      Learning Hub
                    </span>
                  </Link>
                </Button>
              </TooltipTrigger>
              <TooltipContent
                className="group-data-[collapsible=icon]:block group-data-[state=expanded]:hidden"
                side="right"
              >
                Learning Hub
              </TooltipContent>
            </Tooltip>
          </div>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent className="!gap-0 !pt-0 group-data-[collapsible=icon]:hidden">
        <SidebarHistory user={user} />
      </SidebarContent>
    </Sidebar>
  );
}
