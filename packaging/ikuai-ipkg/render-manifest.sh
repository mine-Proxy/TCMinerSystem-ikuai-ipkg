#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
  printf 'Usage: %s <template> <output> <version>\n' "$0" >&2
  exit 1
fi

template="$1"
output="$2"
version="$3"
placeholder='__TCMS_IPKG_VERSION__'

if [ ! -f "${template}" ]; then
  printf 'Template not found: %s\n' "${template}" >&2
  exit 1
fi

if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'Invalid ipkg version: %s\n' "${version}" >&2
  exit 1
fi

if ! grep -q "${placeholder}" "${template}"; then
  printf 'Template placeholder %s not found in %s\n' "${placeholder}" "${template}" >&2
  exit 1
fi

mkdir -p "$(dirname "${output}")"
sed "s/${placeholder}/${version}/g" "${template}" > "${output}"
