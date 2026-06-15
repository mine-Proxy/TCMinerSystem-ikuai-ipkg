#!/usr/bin/env bash
set -eu

DATA_DIR="/root/rustminersystem"
CONFIG_PATH="${DATA_DIR}/rust-config"

mkdir -p "${DATA_DIR}"

set_config() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" "${CONFIG_PATH}" 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${value}|" "${CONFIG_PATH}"
  else
    printf '%s=%s\n' "${key}" "${value}" >> "${CONFIG_PATH}"
  fi
}

touch "${CONFIG_PATH}"
set_config REMOTE_KEY "${REMOTE_KEY:-}"
set_config RMS_PORT "${RMS_PORT:-1800}"
set_config MB_PORT "${MB_PORT:-3333}"
set_config START_PORT "${START_PORT:-${APP_PORT_WEB:-1314}}"
set_config POOLNODE_PORT "${POOLNODE_PORT:-1900}"
set_config ENABLE_WEB_TLS "${ENABLE_WEB_TLS:-0}"

exec /usr/local/bin/tcstminersystem "$@"
