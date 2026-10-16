#!/usr/bin/env bash
# Полная установка voicerec: системные пакеты → сборка whisper.cpp → модель → PATH.
# Повторный запуск безопасен (пересобирает и обновляет).
#   ./setup.sh               всё
#   ./setup.sh --no-packages без apt (пакеты уже стоят или нет sudo)
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
VOICEREC_HOME="$PWD"

install_packages() {
  if ! command -v apt-get >/dev/null; then
    echo "apt не найден — поставьте пакеты вручную, список в README.md" >&2
    return
  fi

  local pkgs=(build-essential cmake git python3 ffmpeg alsa-utils libnotify-bin)
  if command -v nvidia-smi >/dev/null || lspci 2>/dev/null | grep -qi 'vga.*nvidia'; then
    echo "GPU: NVIDIA → CUDA"
    pkgs+=(nvidia-cuda-toolkit)
  elif lspci 2>/dev/null | grep -qiE 'vga.*(amd|ati|intel)'; then
    echo "GPU: AMD/Intel → Vulkan"
    pkgs+=(libvulkan-dev glslc spirv-headers mesa-vulkan-drivers vulkan-tools)
  else
    echo "GPU не найден → CPU"
  fi

  sudo apt-get update
  sudo apt-get install -y "${pkgs[@]}"
}

add_to_path() {
  local line="export PATH=\"$VOICEREC_HOME/bin:\$PATH\""
  if grep -qF "$VOICEREC_HOME/bin" ~/.bashrc 2>/dev/null; then
    echo "PATH: уже в ~/.bashrc"
  else
    printf '\n# voicerec\n%s\n' "$line" >> ~/.bashrc
    echo "PATH: добавлен в ~/.bashrc (откройте новый терминал или: source ~/.bashrc)"
  fi
}

[ "${1:-}" = "--no-packages" ] || install_packages
chmod +x bin/*
VOICEREC_HOME="$VOICEREC_HOME" bin/vr-build
add_to_path

echo
echo "Готово. Проверка: vr   (говорите, Enter — закончить)"
