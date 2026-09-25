#!/usr/bin/env bash
set -euo pipefail

# Extract version from template/metadata.typ and lib/helpers.typ
HES_SO_VERSION_METADATA=$(grep -o '@preview/hes-so-package:[0-9.]\+' template/metadata.typ | head -n1 | awk -F: '{print $2}')
HES_SO_VERSION_HELPERS=$(grep -o '@preview/hes-so-package:[0-9.]\+' lib/helpers.typ | head -n1 | awk -F: '{print $2}')

echo "hes-so-package (metadata.typ): $HES_SO_VERSION_METADATA"
echo "hes-so-package (helpers.typ):  $HES_SO_VERSION_HELPERS"

if [ -z "$HES_SO_VERSION_METADATA" ] || [ -z "$HES_SO_VERSION_HELPERS" ]; then
  echo "Error: Could not extract hes-so-package version from template/metadata.typ or lib/helpers.typ"
  exit 1
fi

if [ "$HES_SO_VERSION_METADATA" != "$HES_SO_VERSION_HELPERS" ]; then
  echo "Error: hes-so-package version mismatch: template/metadata.typ has $HES_SO_VERSION_METADATA but lib/helpers.typ has $HES_SO_VERSION_HELPERS"
  exit 1
fi

HES_SO_VERSION="$HES_SO_VERSION_METADATA"

# Check if the package version is available on Typst Universe
HTTP_STATUS=$(curl -s -L -o /dev/null -I -w "%{http_code}" --max-time 10 "https://packages.typst.org/preview/hes-so-package-${HES_SO_VERSION}.tar.gz" || true)
echo "Typst Universe HTTP status for hes-so-package:${HES_SO_VERSION}: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
  echo "hes-so-package:${HES_SO_VERSION} is available on Typst Universe."
else
  echo "hes-so-package:${HES_SO_VERSION} not available on Typst Universe (HTTP $HTTP_STATUS). Cloning repository tag..."
  TARGET_DIR="${HOME}/.cache/typst/packages/preview/hes-so-package/${HES_SO_VERSION}"
  if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "${HOME}/.cache/typst/packages/preview/hes-so-package"
    git clone --depth 1 --branch "${HES_SO_VERSION}" https://github.com/hes-so/HES-SO-package "$TARGET_DIR" || \
    git clone --depth 1 --branch "v${HES_SO_VERSION}" https://github.com/hes-so/HES-SO-package "$TARGET_DIR"
    echo "Successfully cloned hes-so-package tag ${HES_SO_VERSION} into $TARGET_DIR"
  else
    echo "Package directory $TARGET_DIR already exists."
  fi
fi
