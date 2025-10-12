"use client";

import type { User } from "next-auth";
import { memo, startTransition, useEffect, useState } from "react";
import { saveChatModelAsCookie } from "@/app/(chat)/actions";
import { SidebarToggle } from "@/components/sidebar-toggle";
import { SidebarUserNav } from "@/components/sidebar-user-nav";
import { chatModels } from "@/lib/ai/models";
import {
  PromptInputModelSelect,
  PromptInputModelSelectContent,
  PromptInputModelSelectTrigger,
} from "./elements/prompt-input";
import { CpuIcon } from "./icons";
import { SelectItem } from "./ui/select";

function PureChatHeader({
  selectedModelId,
  onModelChange,
  user,
}: {
  selectedModelId: string;
  onModelChange?: (modelId: string) => void;
  user: User | undefined;
}) {
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
        <PromptInputModelSelectTrigger className="flex h-8 w-fit items-center gap-1.5 rounded-lg border border-input bg-background px-2 text-foreground shadow-sm outline-none ring-0 transition-colors hover:bg-accent hover:text-accent-foreground focus:outline-none focus:ring-0 focus-visible:ring-0 active:bg-accent">
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
