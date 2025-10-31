#!/usr/bin/env bash
set -euo pipefail

msg()  { echo -e "\n\033[1m[$(date +%H:%M:%S)] $*\033[0m"; }
err()  { echo -e "\n\033[31m[ERROR]\033[0m $*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

require_sudo() {
  if [[ $EUID -ne 0 ]]; then
    if ! have sudo; then
      err "sudo не знайдено. Запустіть від root або встановіть sudo."
      exit 1
    fi
    export SUDO="sudo"
  else
    export SUDO=""
  fi
}

detect_os() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_ID="${ID:-}"
    OS_LIKE="${ID_LIKE:-}"
  else
    err "/etc/os-release не знайдено. Непідтримувана ОС."
    exit 1
  fi
}

install_docker_debian() {
  msg "Встановлюю Docker (Debian/Ubuntu)…"
  $SUDO apt-get update -y
  $SUDO apt-get install -y ca-certificates curl gnupg lsb-release

  # GPG key + repo
  if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
    $SUDO install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO chmod a+r /etc/apt/keyrings/docker.gpg
  fi

  echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
$(. /etc/os-release; echo "$VERSION_CODENAME") stable" | $SUDO tee /etc/apt/sources.list.d/docker.list >/dev/null

  $SUDO apt-get update -y
  $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  $SUDO systemctl enable --now docker || true

  # додати користувача в групу docker (щоб працювати без sudo після релогу)
  if getent group docker >/dev/null 2>&1; then
    $SUDO usermod -aG docker "$USER" || true
  fi
}

install_docker_rhel() {
  msg "Встановлюю Docker (RHEL/Fedora/CentOS)…"
  if have dnf; then
    $SUDO dnf -y install dnf-plugins-core
    $SUDO dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo || \
    $SUDO dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    $SUDO dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    $SUDO systemctl enable --now docker || true
  else
    $SUDO yum -y install yum-utils
    $SUDO yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    $SUDO yum -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    $SUDO systemctl enable --now docker || true
  fi

  if getent group docker >/dev/null 2>&1; then
    $SUDO usermod -aG docker "$USER" || true
  fi
}

ensure_docker() {
  if have docker; then
    msg "Docker вже встановлено: $(docker --version)"
  else
    case "$OS_ID:$OS_LIKE" in
      debian:*|ubuntu:*|*:debian*|*:ubuntu*)
        install_docker_debian
        ;;
      fedora:*|rhel:*|centos:*|*:rhel*|*:fedora*|*:centos*)
        install_docker_rhel
        ;;
      *)
        err "Автовстановлення Docker для вашої ОС не налаштовано. Спробуйте офіційний скрипт: https://get.docker.com"
        exit 1
        ;;
    esac
    msg "Docker встановлено: $(docker --version)"
  fi

  # docker compose (плагін) або запасний варіант
  if docker compose version >/dev/null 2>&1; then
    msg "docker compose (plugin) доступний: $(docker compose version)"
  elif have docker-compose; then
    msg "Знайдено standalone docker-compose: $(docker-compose --version)"
  else
    msg "docker compose plugin недоступний — встановлюю standalone через pip як запасний варіант…"
    ensure_python_and_pip
    python_cmd=$(select_python_cmd)
    "$python_cmd" -m pip install --user docker-compose
    msg "Встановлено docker-compose (pip): $(~/.local/bin/docker-compose --version || echo 'OK')"
  fi
}

select_python_cmd() {
  for c in python3.12 python3.11 python3.10 python3.9 python3; do
    if have "$c"; then
      echo "$c"
      return 0
    fi
  done
  echo "python3"
}

version_ge() {
  # порівняння версій: version_ge CURRENT 3.9
  printf '%s\n%s\n' "$1" "$2" | sort -V -C
}

install_python_debian() {
  $SUDO apt-get update -y
  $SUDO apt-get install -y python3 python3-pip
  # Спроба підтягнути новішу, якщо базова <3.9 і доступна в репо
  for pkg in python3.12 python3.11 python3.10 python3.9; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      $SUDO apt-get install -y "$pkg" || true
    fi
  done
}

install_python_rhel() {
  if have dnf; then
    $SUDO dnf -y install python3 python3-pip || true
    for pkg in python3.12 python3.11 python3.10 python3.9; do
      $SUDO dnf -y install "$pkg" || true
    done
  else
    $SUDO yum -y install python3 python3-pip || true
  fi
}

ensure_python_and_pip() {
  msg "Перевіряю Python та pip…"
  if ! have python3; then
    case "$OS_ID:$OS_LIKE" in
      debian:*|ubuntu:*|*:debian*|*:ubuntu*) install_python_debian ;;
      fedora:*|rhel:*|centos:*|*:rhel*|*:fedora*|*:centos*) install_python_rhel ;;
      *) err "Не вдалося автоматично встановити Python для вашої ОС."; exit 1 ;;
    esac
  fi

  local py
  py=$(select_python_cmd)
  local ver
  ver="$($py -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
  if ! version_ge "$ver" "3.9"; then
    msg "Попередження: знайдений Python $ver < 3.9. Спробував встановити новішу версію. Обрано: $py"
  else
    msg "Python OK: $py (версія $ver)"
  fi

  # Переконатися, що pip є
  if ! "$py" -m pip --version >/dev/null 2>&1; then
    msg "Встановлюю pip…"
    case "$OS_ID:$OS_LIKE" in
      debian:*|ubuntu:*|*:debian*|*:ubuntu*) $SUDO apt-get install -y python3-pip ;;
      fedora:*|rhel:*|centos:*|*:rhel*|*:fedora*|*:centos*) $SUDO dnf -y install python3-pip || $SUDO yum -y install python3-pip ;;
    esac
  fi
}

install_django_user() {
  msg "Встановлюю Django (для поточного користувача)…"
  local py
  py=$(select_python_cmd)
  "$py" -m pip install --upgrade --user pip >/dev/null 2>&1 || true
  "$py" -m pip install --user "Django>=4.0"
  local binpath="$HOME/.local/bin"
  if [[ ":$PATH:" != *":$binpath:"* ]]; then
    msg "Додаю $binpath у PATH (для поточної сесії)."
    export PATH="$binpath:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc" || true
  fi
  msg "Django встановлено: $("$HOME/.local/bin/django-admin" --version 2>/dev/null || echo "OK")"
}

require_sudo
detect_os

msg "=== Крок 1/3: Docker & docker compose ==="
ensure_docker

msg "=== Крок 2/3: Python >= 3.9 + pip ==="
ensure_python_and_pip

msg "=== Крок 3/3: Django ==="
install_django_user

msg "=== Підсумок версій ==="
docker --version || true
docker compose version || docker-compose --version || true
($(select_python_cmd)) --version || true
($(select_python_cmd)) -m pip --version || true
"$HOME/.local/bin/django-admin" --version 2>/dev/null || true

msg "Готово! Якщо ви щойно додані в групу docker — перелогіньтеся, щоб використовувати docker без sudo."
