#!/bin/bash
# TCMinerSystem ipkg 打包脚本 / Build script for iKuai v4 ipkg package
# 用法 / Usage: VERSION=5.0.0 BINARY_URL= bash build-ipkg.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
STAGE_DIR="$SCRIPT_DIR/.stage"
PACKAGE_TEMPLATE_DIR="$SCRIPT_DIR/tcminersystem"
PACKAGE_STAGE_DIR="$STAGE_DIR/package/tcminersystem"
MANIFEST_TEMPLATE="$PACKAGE_TEMPLATE_DIR/manifest.template.json"
RENDER_MANIFEST_SCRIPT="$SCRIPT_DIR/render-manifest.sh"
BINARY_DOWNLOAD_DIR="$STAGE_DIR/download"

VERSION="${VERSION:-5.0.0}"
BINARY_URL="${BINARY_URL:-https://github.com/mine-Proxy/TCMinerSystem/raw/refs/heads/main/linux/tcstminersystem-${VERSION}}"

echo "=== 构建 TCMinerSystem v${VERSION} ipkg ==="

PACKAGE_NAME="tcminersystem-x86_64.ipkg"

# 步骤 1：准备暂存目录 / Step 1: Prepare staging
echo "[1/6] 准备暂存目录..."
rm -rf "$STAGE_DIR"
mkdir -p "$BINARY_DOWNLOAD_DIR" "$PACKAGE_STAGE_DIR"

# 步骤 2：下载二进制 / Step 2: Download binary
echo "[2/6] 下载二进制文件..."
echo "    下载地址: ${BINARY_URL}"
curl -fsSL -o "$BINARY_DOWNLOAD_DIR/tcstminersystem" "$BINARY_URL"
chmod +x "$BINARY_DOWNLOAD_DIR/tcstminersystem"
file "$BINARY_DOWNLOAD_DIR/tcstminersystem"

# 步骤 3：渲染 manifest.json / Step 3: Render manifest.json
echo "[3/6] 渲染 manifest.json..."
cp -R "$PACKAGE_TEMPLATE_DIR/." "$PACKAGE_STAGE_DIR/"
rm -f "$PACKAGE_STAGE_DIR/manifest.template.json" "$PACKAGE_STAGE_DIR/docker_image.tar.gz"
bash "$RENDER_MANIFEST_SCRIPT" "$MANIFEST_TEMPLATE" "$PACKAGE_STAGE_DIR/manifest.json" "$VERSION"

# 步骤 4：组装 Docker 镜像 / Step 4: Assemble Docker image
echo "[4/6] 组装 Docker 镜像..."
cp "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR/docker-entrypoint.sh" "$STAGE_DIR/"
mkdir -p "$STAGE_DIR/docker/bin/linux-amd64"
cp "$BINARY_DOWNLOAD_DIR/tcstminersystem" "$STAGE_DIR/docker/bin/linux-amd64/tcstminersystem"
cd "$STAGE_DIR"
docker build --build-arg TARGETPLATFORM=linux/amd64 -t tcminersystem:ikuai .

# 步骤 5：导出镜像为离线安装包 / Step 5: Export image as offline package
echo "[5/6] 导出 Docker 镜像..."
docker save tcminersystem:ikuai | gzip > "$PACKAGE_STAGE_DIR/docker_image.tar.gz"
IMAGE_SIZE=$(du -h "$PACKAGE_STAGE_DIR/docker_image.tar.gz" | cut -f1)
echo "    镜像大小 / Image size: ${IMAGE_SIZE}"

# 步骤 6：打包 ipkg / Step 6: Pack ipkg
echo "[6/6] 打包 ipkg..."
tar -czf "$SCRIPT_DIR/${PACKAGE_NAME}" -C "$STAGE_DIR/package" tcminersystem/
IPKG_SIZE=$(du -h "$SCRIPT_DIR/${PACKAGE_NAME}" | cut -f1)

rm -rf "$STAGE_DIR"

echo ""
echo "=== 完成 / Done ==="
echo "输出 / Output: ${PACKAGE_NAME} (${IPKG_SIZE})"
echo ""
echo "安装方式 / Install on iKuai v4:"
echo "  Web: 高级应用 → 应用市场 → 本地安装"
