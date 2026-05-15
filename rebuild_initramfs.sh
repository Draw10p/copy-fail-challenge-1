#!/bin/bash
# Script para reconstruir el initramfs.cpio.gz

set -euo pipefail

WORKSPACE_ROOT="/workspaces/copy-fail-challenge-1"
INITRAMFS_DIR="$WORKSPACE_ROOT/kernel/initramfs"
BUILD_DIR="$WORKSPACE_ROOT/kernel/build"

echo "[*] Recreando initramfs.cpio.gz..."

# Verificar que el directorio initramfs existe
if [ ! -d "$INITRAMFS_DIR" ]; then
    echo "ERROR: $INITRAMFS_DIR no existe"
    exit 1
fi

# Asegurar que /init existe y es ejecutable
if [ ! -f "$INITRAMFS_DIR/init" ]; then
    echo "ERROR: /init no existe en el initramfs"
    exit 1
fi

# Hacer el init ejecutable
chmod +x "$INITRAMFS_DIR/init"

# Empaquetar
cd "$INITRAMFS_DIR"
echo "[*] Empaquetando con cpio..."
find . -print0 | cpio --null -ov -H newc | gzip > "$BUILD_DIR/initramfs.cpio.gz" 2>&1

if [ -f "$BUILD_DIR/initramfs.cpio.gz" ]; then
    SIZE=$(du -h "$BUILD_DIR/initramfs.cpio.gz" | cut -f1)
    echo "[✓] initramfs.cpio.gz creado ($SIZE)"
    ls -lah "$BUILD_DIR/initramfs.cpio.gz"
else
    echo "ERROR: No se pudo crear initramfs.cpio.gz"
    exit 1
fi

echo ""
echo "[✓] Ahora puedes ejecutar: make qemu"
