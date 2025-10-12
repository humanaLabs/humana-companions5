import { generateDummyPassword } from "./db/utils";

export const isProductionEnvironment = process.env.NODE_ENV === "production";
export const isDevelopmentEnvironment = process.env.NODE_ENV === "development";
export const isTestEnvironment = Boolean(
  process.env.PLAYWRIGHT_TEST_BASE_URL ||
    process.env.PLAYWRIGHT ||
    process.env.CI_PLAYWRIGHT
);

export const guestRegex = /^guest-\d+$/;

export const DUMMY_PASSWORD = generateDummyPassword();

// Chat version configuration
// Supported versions: "v1", "v2", "v3", "v4", "v5"
// Default is "v1" if not set or invalid
export const DEFAULT_CHAT_VERSION = (
  process.env.HUMANA_DEFAULT_CHAT_VERSION || "v1"
).toLowerCase() as "v1" | "v2" | "v3" | "v4" | "v5";

// Validate the version
const VALID_VERSIONS = ["v1", "v2", "v3", "v4", "v5"];
export const CHAT_VERSION = VALID_VERSIONS.includes(DEFAULT_CHAT_VERSION)
  ? DEFAULT_CHAT_VERSION
  : "v1";
