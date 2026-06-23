# copilot-api-docker

使用 Docker 运行 [@jeffreycao/copilot-api@latest](https://www.npmjs.com/package/@jeffreycao/copilot-api)，将 GitHub Copilot 封装为兼容 Anthropic 接口的本地服务，供 Claude Code 等工具调用。

服务基于 Node 22 Alpine 镜像构建，监听 `4141` 端口，并将认证数据持久化到宿主机 `~/.local/share/copilot-api`。

## 使用步骤

### 1. 本地完成 Copilot 认证

在宿主机执行以下命令，按提示登录 GitHub Copilot：

```bash
npx @jeffreycao/copilot-api@latest auth
```

该步骤会在 `~/.local/share/copilot-api` 目录下生成认证文件。该目录会被映射进容器，因此容器无需重复认证。

### 2. 启动容器

```bash
docker-compose up -d
```

容器会以 `copilot-api` 为名启动，监听宿主机的 `4141` 端口（`http://localhost:4141`），并随 Docker 自动重启。

服务启动后，会生成 Copilot 使用量看板 URL，例如：

```text
http://localhost:4141/usage-viewer?endpoint=http://localhost:4141/usage
```

这个看板是用于监控 API 用量的 Web 界面。如果怀疑 token 过期，可通过 `curl http://localhost:4141/usage` 或打开 Web 看板来确认。

使用量看板说明：

- **API Endpoint URL**：看板会通过 URL 查询参数，默认从本地服务端点拉取数据。你也可以把这个 URL 改成任意其他兼容 API 端点。
- **Fetch Data**：点击 “Fetch” 按钮即可加载或刷新使用数据。页面首次加载时也会自动拉取。
- **Usage Quotas**：使用进度条汇总展示 Chat、Completions 等不同服务的额度使用情况。
- **Detailed Information**：可查看 API 返回的完整 JSON，以便深入分析所有可用统计信息。
- **URL-based Configuration**：你也可以直接通过 URL 查询参数指定 API 端点，便于收藏或分享。例如：`http://localhost:4141/usage-viewer?endpoint=http://your-api-server/usage`。

### 3. 配置 Claude Code

修改 `~/.claude/settings.json`，将 `env` 配置为指向本地服务：

```json
{
  "env": {
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "80",
    "ANTHROPIC_BASE_URL": "http://localhost:4141",
    "ANTHROPIC_AUTH_TOKEN": "dummy",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-4.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4.6",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4.8",
    "ANTHROPIC_DEFAULT_FABLE_MODEL": "claude-opus-4.8",
    "DISABLE_NON_ESSENTIAL_MODEL_CALLS": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "API_TIMEOUT_MS": "3000000"
  }
}
```

说明：

- `CLAUDE_CODE_SUBAGENT_MODEL`：指定子代理（subagent）使用的模型，这里用轻量的 `haiku`。
- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`：上下文占用达到该百分比时触发自动压缩。
- `ANTHROPIC_BASE_URL`：指向容器暴露的本地服务地址。
- `ANTHROPIC_AUTH_TOKEN`：本地服务不校验 token，填任意值（如 `dummy`）即可。
- `ANTHROPIC_DEFAULT_HAIKU_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL` / `ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_FABLE_MODEL`：分别为 Haiku、Sonnet、Opus、Fable 各档位映射实际使用的模型，可按需调整。
- `API_TIMEOUT_MS`：放宽请求超时时间，避免长任务被中断。

配置完成后重新启动 Claude Code，即可通过本地 copilot-api 服务使用。

## 可用模型

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

## 本地 copilot-api 命令

在宿主机直接使用 `copilot-api` 的命令行工具：

```bash
npx @jeffreycao/copilot-api@latest start

npx @jeffreycao/copilot-api@latest auth

npx @jeffreycao/copilot-api@latest debug
```

各命令说明：

- `start`：启动 Copilot API 服务，必要时会自动处理认证。
- `auth`：只跑 GitHub 认证流程而不启动服务，适用于非交互环境或需要为 `--github-token` 生成 token 的场景。
- `debug`：显示版本、运行时细节、文件路径与认证状态等诊断信息，便于排查与求助。

## 致谢

本项目基于 [caozhiyuan/copilot-api](https://github.com/caozhiyuan/copilot-api) 提供的 copilot-api 服务，仅在其之上封装了 Docker 部署方案。
