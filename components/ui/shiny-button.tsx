"use client";

import { type HTMLMotionProps, motion } from "framer-motion";
import React from "react";

import { cn } from "@/lib/utils";

const getAnimationProps = (delay = 0) => ({
  initial: { "--x": "100%", scale: 0.8 } as const,
  animate: { "--x": "-100%", scale: 1 } as const,
  whileTap: { scale: 0.95 },
  transition: {
    repeat: Number.POSITIVE_INFINITY,
    repeatType: "loop" as const,
    repeatDelay: 1,
    delay,
    type: "spring" as const,
    stiffness: 20,
    damping: 15,
    mass: 2,
    scale: {
      type: "spring" as const,
      stiffness: 200,
      damping: 5,
      mass: 0.5,
    },
  },
});

interface ShinyButtonProps extends HTMLMotionProps<"button"> {
  children: React.ReactNode;
  className?: string;
  animationDelay?: number;
}

export const ShinyButton = React.forwardRef<
  HTMLButtonElement,
  ShinyButtonProps
>(({ children, className, animationDelay = 0, ...props }, ref) => {
  return (
    <motion.button
      className={cn(
        "relative cursor-pointer rounded-lg border px-6 py-2 font-medium backdrop-blur-xl transition-shadow duration-300 ease-in-out hover:shadow dark:bg-[radial-gradient(circle_at_50%_0%,var(--primary)/8%_0%,transparent_60%)] dark:hover:shadow-[0_0_15px_var(--primary)/8%]",
        className
      )}
      ref={ref}
      {...getAnimationProps(animationDelay)}
      {...props}
    >
      <span
        className="relative flex size-full items-center text-[rgb(0,0,0,65%)] text-sm tracking-wide dark:font-light dark:text-[rgb(255,255,255,90%)]"
        style={{
          maskImage:
            "linear-gradient(-75deg,var(--primary) calc(var(--x) + 20%),transparent calc(var(--x) + 30%),var(--primary) calc(var(--x) + 100%))",
        }}
      >
        {children}
      </span>
      <span
        className="absolute inset-0 z-10 block rounded-[inherit] p-px opacity-50"
        style={{
          mask: "linear-gradient(rgb(0,0,0), rgb(0,0,0)) content-box exclude,linear-gradient(rgb(0,0,0), rgb(0,0,0))",
          WebkitMask:
            "linear-gradient(rgb(0,0,0), rgb(0,0,0)) content-box exclude,linear-gradient(rgb(0,0,0), rgb(0,0,0))",
          backgroundImage:
            "linear-gradient(-75deg,var(--primary)/8% calc(var(--x)+20%),var(--primary)/30% calc(var(--x)+25%),var(--primary)/8% calc(var(--x)+100%))",
        }}
      />
    </motion.button>
  );
});

ShinyButton.displayName = "ShinyButton";
