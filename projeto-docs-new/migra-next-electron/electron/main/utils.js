"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isDevelopment = isDevelopment;
exports.npxCmd = npxCmd;
exports.getStartUrl = getStartUrl;
function isDevelopment() {
    return process.env.NODE_ENV === "development";
}
function npxCmd() {
    return process.platform === "win32" ? "npx.cmd" : "npx";
}
function getStartUrl() {
    // Em desenvolvimento, tenta localhost primeiro
    // Usa variável de ambiente ou default para localhost:3000
    if (isDevelopment() || !process.env.ELECTRON_START_URL) {
        return process.env.ELECTRON_START_URL || "http://localhost:3000";
    }
    return "https://chat.vercel.ai";
}
//# sourceMappingURL=utils.js.map