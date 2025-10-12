"use client";

import { useRouter } from "next/navigation";
import type { User } from "next-auth";
import { memo, startTransition, useEffect, useState } from "react";
import { useWindowSize } from "usehooks-ts";
import { saveChatModelAsCookie } from "@/app/(chat)/actions";
import { SidebarToggle } from "@/components/sidebar-toggle";
import { SidebarUserNav } from "@/components/sidebar-user-nav";
import { Button } from "@/components/ui/button";
import { chatModels } from "@/lib/ai/models";
import {
  PromptInputModelSelect,
  PromptInputModelSelectContent,
  PromptInputModelSelectTrigger,
} from "./elements/prompt-input";
import { CpuIcon, PlusIcon } from "./icons";
import { SelectItem } from "./ui/select";
import { useSidebar } from "./ui/sidebar";

function PureChatHeader({
  selectedModelId,
  onModelChange,
  user,
}: {
  selectedModelId: string;
  onModelChange?: (modelId: string) => void;
  user: User | undefined;
}) {
  const router = useRouter();
  const { open } = useSidebar();

  const { width: windowWidth } = useWindowSize();

  const [optimisticModelId, setOptimisticModelId] = useState(selectedModelId);

  useEffect(() => {
    setOptimisticModelId(selectedModelId);
  }, [selectedModelId]);

  const selectedModel = chatModels.find(
    (model) => model.id === optimisticModelId
  );

  return (
    <header className="sticky top-0 flex items-center gap-2 bg-background px-2 py-1.5 md:px-2">
      <SidebarToggle />

      <PromptInputModelSelect
        onValueChange={(modelName) => {
          const model = chatModels.find((m) => m.name === modelName);
          if (model) {
            setOptimisticModelId(model.id);
            onModelChange?.(model.id);
            startTransition(() => {
              saveChatModelAsCookie(model.id);
            });
          }
        }}
        value={selectedModel?.name}
      >
        <PromptInputModelSelectTrigger className="flex h-8 w-fit items-center gap-1.5 rounded-lg border border-input bg-background px-2 text-foreground shadow-sm transition-colors hover:bg-accent hover:text-accent-foreground">
          <CpuIcon size={14} />
          <span className="font-medium text-xs">{selectedModel?.name}</span>
        </PromptInputModelSelectTrigger>
        <PromptInputModelSelectContent align="start" className="w-[280px]">
          {chatModels.map((model) => (
            <SelectItem
              className="cursor-pointer"
              key={model.id}
              value={model.name}
            >
              <div className="flex flex-col">
                <div className="truncate font-medium text-sm">{model.name}</div>
                <div className="mt-0.5 truncate text-muted-foreground text-xs leading-tight">
                  {model.description}
                </div>
              </div>
            </SelectItem>
          ))}
        </PromptInputModelSelectContent>
      </PromptInputModelSelect>

      {(!open || windowWidth < 768) && (
        <Button
          className="h-8 px-2 md:h-fit md:px-2"
          onClick={() => {
            router.push("/");
            router.refresh();
          }}
          variant="outline"
        >
          <PlusIcon />
          <span className="md:sr-only">New Chat</span>
        </Button>
      )}

      <div className="ml-auto">{user && <SidebarUserNav user={user} />}</div>
    </header>
  );
}

export const ChatHeader = memo(PureChatHeader, (prevProps, nextProps) => {
  return (
    prevProps.selectedModelId === nextProps.selectedModelId &&
    prevProps.user?.email === nextProps.user?.email
  );
});
