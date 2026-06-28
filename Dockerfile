# 基于官方Node.js镜像，选用LTS稳定版
FROM node:22-alpine

# 设置工作目录
WORKDIR /app

# 安装基础依赖（alpine缺少部分运行依赖）
RUN apk add --no-cache git openssh

# 全局提前安装copilot-api最新版（可选，加速启动，npx仍会校验最新）
RUN npm install -g @jeffreycao/copilot-api@latest

# 修复：禁用 WebSocket 连接池的过期复用（默认 60s 空闲复用会复用被上游关闭的死连接，
# 导致 Codex 报 "stream closed before response.completed"）。将空闲超时设为 0 = 不跨请求复用。
# 构建时断言：若上游版本改名该常量导致补丁未命中，则构建失败提醒（避免补丁静默失效、bug 回归）。
RUN PKG=/usr/local/lib/node_modules/@jeffreycao/copilot-api/dist; \
    find "$PKG" -name '*.js' -exec sed -i 's/DEFAULT_WEBSOCKET_IDLE_TIMEOUT_MS = 6e4/DEFAULT_WEBSOCKET_IDLE_TIMEOUT_MS = 0/g' {} +; \
    grep -rq 'DEFAULT_WEBSOCKET_IDLE_TIMEOUT_MS = 0' "$PKG" \
      || { echo 'ERROR: websocket idle-timeout patch did not apply (constant renamed upstream?)'; exit 1; }

# 暴露服务端口4141
EXPOSE 4141

# 持久化数据目录：宿主机 ~/.local/share/copilot-api 映射容器同路径
VOLUME ["/root/.local/share/copilot-api"]

# 容器启动命令：直接运行已打补丁的全局安装（不用 npx @latest，否则启动时会重新拉取未打补丁的版本）
CMD ["copilot-api", "start"]
