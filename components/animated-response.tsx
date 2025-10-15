"use client";

import { type ComponentProps, memo, useEffect, useRef, useState } from "react";
import { Streamdown } from "streamdown";
import { cn } from "@/lib/utils";

type AnimatedResponseProps = ComponentProps<typeof Streamdown> & {
  enableBlurEffect?: boolean;
};

export const AnimatedResponse = memo(
  ({
    className,
    enableBlurEffect = false,
    children,
    ...props
  }: AnimatedResponseProps) => {
    const containerRef = useRef<HTMLDivElement>(null);
    const processedNodesRef = useRef<WeakSet<Node>>(new WeakSet());
    const [_shouldAnimate, _setShouldAnimate] = useState(true);

    useEffect(() => {
      if (!enableBlurEffect || !containerRef.current) {
        return;
      }

      const container = containerRef.current;

      // Apply initial animation to all elements
      const applyInitialAnimation = () => {
        const allElements = container.querySelectorAll("*");
        allElements.forEach((element) => {
          if (
            element instanceof HTMLElement &&
            !processedNodesRef.current.has(element)
          ) {
            processedNodesRef.current.add(element);
            element.style.animation =
              "blur-in-content 0.5s cubic-bezier(0.2, 0, 0.4, 1) forwards";
            element.style.opacity = "0";
            element.style.filter = "blur(8px)";

            setTimeout(() => {
              element.style.animation = "";
              element.style.opacity = "";
              element.style.filter = "";
            }, 500);
          }
        });
      };

      // Apply animation to new nodes during streaming
      const applyBlurToNewNodes = (mutations: MutationRecord[]) => {
        mutations.forEach((mutation) => {
          mutation.addedNodes.forEach((node) => {
            if (processedNodesRef.current.has(node)) {
              return;
            }

            if (node.nodeType === Node.ELEMENT_NODE) {
              const element = node as HTMLElement;
              processedNodesRef.current.add(node);

              element.style.animation =
                "blur-in-content 0.5s cubic-bezier(0.2, 0, 0.4, 1) forwards";
              element.style.opacity = "0";
              element.style.filter = "blur(8px)";

              setTimeout(() => {
                element.style.animation = "";
                element.style.opacity = "";
                element.style.filter = "";
              }, 500);
            }
          });

          if (
            mutation.type === "characterData" &&
            mutation.target.parentElement
          ) {
            const parent = mutation.target.parentElement;
            if (!processedNodesRef.current.has(parent)) {
              processedNodesRef.current.add(parent);
              parent.style.animation =
                "blur-in-content 0.5s cubic-bezier(0.2, 0, 0.4, 1) forwards";

              setTimeout(() => {
                parent.style.animation = "";
              }, 500);
            }
          }
        });
      };

      // Small delay to ensure DOM is ready
      const timeoutId = setTimeout(() => {
        applyInitialAnimation();
      }, 10);

      const observer = new MutationObserver(applyBlurToNewNodes);

      observer.observe(container, {
        childList: true,
        subtree: true,
        characterData: true,
      });

      return () => {
        clearTimeout(timeoutId);
        observer.disconnect();
      };
    }, [enableBlurEffect]);

    return (
      <div ref={containerRef}>
        <Streamdown
          className={cn(
            "size-full [&>*:first-child]:mt-0 [&>*:last-child]:mb-0 [&_code]:whitespace-pre-wrap [&_code]:break-words [&_pre]:max-w-full [&_pre]:overflow-x-auto",
            className
          )}
          {...props}
        >
          {children}
        </Streamdown>
      </div>
    );
  },
  (prevProps, nextProps) => prevProps.children === nextProps.children
);

AnimatedResponse.displayName = "AnimatedResponse";
