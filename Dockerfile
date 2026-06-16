# 基于官方Node.js镜像，选用LTS稳定版
FROM node:22-alpine

# 设置工作目录
WORKDIR /app

# 安装基础依赖（alpine缺少部分运行依赖）
RUN apk add --no-cache git openssh

# 全局提前安装copilot-api最新版（可选，加速启动，npx仍会校验最新）
RUN npm install -g copilot-api@latest

# 暴露服务端口4141
EXPOSE 4141

# 持久化数据目录：宿主机 ~/.local/share/copilot-api 映射容器同路径
VOLUME ["/root/.local/share/copilot-api"]

# 容器启动命令：启动copilot-api服务
CMD ["npx", "copilot-api@latest", "start"]
