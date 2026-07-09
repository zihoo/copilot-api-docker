#!/bin/sh
CONFIG_DIR=/root/.local/share/copilot-api
TOKEN_FILE="$CONFIG_DIR/github_token"

# 如果 token 文件不存在或为空，先执行认证
if [ ! -s "$TOKEN_FILE" ]; then
  echo "[entrypoint] No valid token found, starting authentication..."
  echo "[entrypoint] Please open the URL below in your browser to authorize."
  echo ""
  copilot-api auth login --provider copilot
  echo ""
  echo "[entrypoint] Authentication complete. Starting service..."
fi

exec copilot-api start --provider copilot
