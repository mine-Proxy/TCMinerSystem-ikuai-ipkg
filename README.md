# TCMinerSystem-ikuai-ipkg

TCMinerSystem 的 iKuai v4 应用市场 ipkg 打包工具。

## 目录结构

```
packaging/ikuai-ipkg/
├── build-ipkg.sh           # 打包脚本
├── render-manifest.sh      # 渲染 manifest.json
├── Dockerfile              # debian:bookworm-slim 基础镜像
├── docker-entrypoint.sh    # 容器入口
└── tcminersystem/          # ipkg 包模板
    ├── manifest.template.json
    ├── readme
    ├── changelog
    ├── ui/ico/app.png      # 应用图标
    ├── log/
    └── app/                # iKuai 应用配置
        ├── docker-compose.yaml
        ├── .env
        └── option.json
```

运行数据持久化在爱快应用目录的 `data/tcminersystem` 下，容器内路径为 `/root/rustminersystem`，包含 `rust-config`、数据库和运行日志等文件。

配置文件职责：`option.json` 定义爱快界面可编辑项，`.env` 是 Docker Compose 默认变量文件并承载 `scope=config` 的默认值。容器启动时会把爱快界面配置同步到持久化目录里的 `rust-config`。

## 本地打包

### 前置要求

- Docker
- curl

### 执行打包

```bash
cd packaging/ikuai-ipkg

# 使用自定义版本
VERSION=5.0.0

# 使用自定义下载地址
BINARY_URL=https://github.com/mine-Proxy/TCMinerSystem/raw/refs/heads/main/linux/tcstminersystem-5.0.0
# 构建
bash build-ipkg.sh
```

输出文件: `packaging/ikuai-ipkg/tcminersystem-x86_64.ipkg`

### iKuai 安装方式

爱快 Web: **高级应用 → 应用市场 → 本地安装**，选择 ipkg 文件上传即可。

## CI 自动打包

GitHub Actions 通过 `workflow_dispatch` 手动触发：

1. 进入仓库 Actions 页面
2. 选择 **Build iKuai ipkg** 工作流
3. 填写参数：
   - `version` — 版本号（默认 `5.0.0`）
   - `binary_url` — 二进制下载地址（留空自动拼接）
   - `release_notes` — 更新说明（默认 `update`）
   - `publish_release` — 是否创建 GitHub Release
4. 执行后可在 Artifacts 下载 ipkg 文件
