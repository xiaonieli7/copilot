// 统一的 API URL 构造函数
// 优先从 Vite 环境变量读取；并兼容旧的 process.env 读取方式（某些构建模式可能会注入）
const envBase = import.meta.env?.VITE_APP_BASE_URL as string | undefined
const processBase = (typeof process !== "undefined" ? (process.env as any)?.APP_BASE_URL : "") as string

let BASE = envBase || processBase || ""

// 开发兜底：如果没配 BASE，在开发模式下尝试直连后端
if (!BASE && typeof window !== "undefined") {
  const isDev = import.meta.env.DEV || window.location.port === "5173";
  if (isDev) {
    // 自动指向当前主机的 6039 端口
    BASE = `${window.location.protocol}//${window.location.hostname}:6039`;
    console.log("[DEBUG] Development mode detected, auto-base set to:", BASE);
  }
}

console.log("[DEBUG] API BASE URL initialized:", {
  VITE_APP_BASE_URL: envBase,
  APP_BASE_URL: processBase,
  FINAL_BASE: BASE,
})

export const apiUrl = (path: string) => {
  const result = BASE
    ? path.startsWith("/")
      ? `${BASE}${path}`
      : `${BASE}/${path}`
    : path

  if (path.includes("import-zip")) {
    console.log("[DEBUG] apiUrl called for import-zip:", { input: path, output: result })
  }

  return result
}
