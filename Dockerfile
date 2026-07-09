FROM node:22-alpine

WORKDIR /app

RUN apk add --no-cache git openssh

RUN npm install -g @jeffreycao/copilot-api@latest

RUN PKG=/usr/local/lib/node_modules/@jeffreycao/copilot-api/dist; \
    find "$PKG" -name '*.js' -exec sed -i 's/DEFAULT_WEBSOCKET_IDLE_TIMEOUT_MS = 6e4/DEFAULT_WEBSOCKET_IDLE_TIMEOUT_MS = 0/g' {} +; \
    grep -rq 'DEFAULT_WEBSOCKET_IDLE_TIMEOUT_MS = 0' "$PKG" \
      || { echo 'ERROR: websocket idle-timeout patch did not apply (constant renamed upstream?)'; exit 1; }

EXPOSE 4141

VOLUME ["/root/.local/share/copilot-api"]

COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
