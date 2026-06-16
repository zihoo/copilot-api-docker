# copilot-api-docker

使用 Docker 运行 [copilot-api](https://www.npmjs.com/package/copilot-api)，将 GitHub Copilot 封装为兼容 Anthropic 接口的本地服务，供 Claude Code 等工具调用。

服务基于 Node 22 Alpine 镜像构建，监听 `4141` 端口，并将认证数据持久化到宿主机 `~/.local/share/copilot-api`。

## 使用步骤

### 1. 本地完成 Copilot 认证

在宿主机执行以下命令，按提示登录 GitHub Copilot：

```bash
npx copilot-api@latest auth
```

该步骤会在 `~/.local/share/copilot-api` 目录下生成认证文件。该目录会被映射进容器，因此容器无需重复认证。

### 2. 启动容器

```bash
docker-compose up -d
```

容器会以 `copilot-api` 为名启动，监听宿主机的 `4141` 端口（`http://localhost:4141`），并随 Docker 自动重启。


### 3. 配置 Claude Code

修改 `~/.claude/settings.json`，将 `env` 配置为指向本地服务：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:4141",
    "ANTHROPIC_AUTH_TOKEN": "dummy",
    "ANTHROPIC_MODEL": "claude-opus-4.8",
    "ANTHROPIC_SMALL_FAST_MODEL": "claude-sonnet-4.6",
    "DISABLE_NON_ESSENTIAL_MODEL_CALLS": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "API_TIMEOUT_MS": "3000000"
  }
}
```

说明：

- `ANTHROPIC_BASE_URL`：指向容器暴露的本地服务地址。
- `ANTHROPIC_AUTH_TOKEN`：本地服务不校验 token，填任意值（如 `dummy`）即可。
- `ANTHROPIC_MODEL` / `ANTHROPIC_SMALL_FAST_MODEL`：分别指定主模型与轻量快速模型，可按需调整。
- `API_TIMEOUT_MS`：放宽请求超时时间，避免长任务被中断。

配置完成后重新启动 Claude Code，即可通过本地 copilot-api 服务使用。

## 可用模型

可在 `ANTHROPIC_MODEL` 与 `ANTHROPIC_SMALL_FAST_MODEL` 中按需填写以下模型：

### Anthropic Claude

- Claude Opus 4.8
- Claude Opus 4.7
- Claude Opus 4.6
- Claude Opus 4.5
- Claude Sonnet 4.6
- Claude Sonnet 4.5
- Claude Haiku 4.5

### OpenAI GPT

- GPT-5.5
- GPT-5.4
- GPT-5.4 mini
- GPT-5 mini

### Google Gemini

- Gemini 3.5 Flash
- Gemini 2.5 Pro

## 致谢

本项目基于 [ericc-ch/copilot-api](https://github.com/ericc-ch/copilot-api) 提供的 copilot-api 服务，仅在其之上封装了 Docker 部署方案。
