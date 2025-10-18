"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createWindow = createWindow;
const node_path_1 = __importDefault(require("node:path"));
const electron_1 = require("electron");
const utils_1 = require("./utils");
function createWindow() {
    const window = new electron_1.BrowserWindow({
        width: 1280,
        height: 800,
        minWidth: 800,
        minHeight: 600,
        backgroundColor: "#ffffff",
        autoHideMenuBar: true, // Ocultar menu
        webPreferences: {
            preload: node_path_1.default.join(__dirname, "../preload/index.js"),
            nodeIntegration: false,
            contextIsolation: true,
            sandbox: true,
            webSecurity: true,
            allowRunningInsecureContent: false,
        },
        show: false,
    });
    // Mostrar janela quando estiver pronta
    window.once("ready-to-show", () => {
        window.show();
    });
    // Abrir links externos no navegador
    window.webContents.setWindowOpenHandler(({ url }) => {
        if (url.startsWith("http://") || url.startsWith("https://")) {
            electron_1.shell.openExternal(url);
        }
        return { action: "deny" };
    });
    // Allowlist de navegação
    window.webContents.on("will-navigate", (event, url) => {
        const allowedOrigins = [
            "http://localhost:3000",
            "http://localhost:3001",
            "https://chat.vercel.ai",
        ];
        const allowed = allowedOrigins.some((origin) => url.startsWith(origin));
        if (!allowed) {
            event.preventDefault();
            console.warn("[Security] Navegação bloqueada:", url);
        }
    });
    // Logs úteis em dev
    if ((0, utils_1.isDevelopment)()) {
        window.webContents.on("did-fail-load", (_event, errorCode, errorDescription) => {
            console.error("[Window] Falha ao carregar:", errorCode, errorDescription);
        });
        window.webContents.on("console-message", (_event, _level, message) => {
            console.log("[Renderer]", message);
        });
    }
    return window;
}
//# sourceMappingURL=window.js.map