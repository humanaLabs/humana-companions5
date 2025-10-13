import type { HTMLAttributes } from "react";
import { cn } from "@/lib/utils";

type LoaderIconProps = {
  size?: number;
};

const LoaderIcon = ({ size = 16 }: LoaderIconProps) => (
  <svg
    height={size}
    style={{ color: "currentcolor" }}
    viewBox="0 0 24 24"
    width={size}
  >
    <title>Typing</title>
    <circle
      cx="4"
      cy="12"
      fill="currentColor"
      r="2"
      style={{
        animation: "pulse 1.4s ease-in-out 0s infinite",
      }}
    />
    <circle
      cx="12"
      cy="12"
      fill="currentColor"
      r="2"
      style={{
        animation: "pulse 1.4s ease-in-out 0.2s infinite",
      }}
    />
    <circle
      cx="20"
      cy="12"
      fill="currentColor"
      r="2"
      style={{
        animation: "pulse 1.4s ease-in-out 0.4s infinite",
      }}
    />
    <style>
      {`
        @keyframes pulse {
          0%, 60%, 100% {
            opacity: 0.3;
            transform: scale(0.8);
          }
          30% {
            opacity: 1;
            transform: scale(1.1);
          }
        }
      `}
    </style>
  </svg>
);

export type LoaderProps = HTMLAttributes<HTMLDivElement> & {
  size?: number;
};

export const Loader = ({ className, size = 16, ...props }: LoaderProps) => (
  <div
    className={cn("inline-flex items-center justify-center", className)}
    {...props}
  >
    <LoaderIcon size={size} />
  </div>
);
