#!/usr/bin/env bash
set -euo pipefail

GLOBAL=true
DRY_RUN=false

for arg in "$@"; do
  case $arg in
    --local) GLOBAL=false ;;
    --dry-run) DRY_RUN=true ;;
  esac
done

if [ "$GLOBAL" = true ]; then
  TARGET_SKILLS="$HOME/.gemini/antigravity-cli/skills"
  TARGET_RULES="$HOME/.gemini/antigravity-cli/rules"
else
  TARGET_SKILLS="$(pwd)/.agents/skills"
  TARGET_RULES="$(pwd)/.agents/rules"
fi

echo "============================================="
echo "   Antigravity Skills & Rules Installer"
echo "============================================="
echo "Целевая директория Skills: $TARGET_SKILLS"
echo "Целевая директория Rules:  $TARGET_RULES"
echo ""

SKILLS=("pipeline" "launch-web" "launch-security")

for skill in "${SKILLS[@]}"; do
  FROM="./skills/$skill"
  DEST="$TARGET_SKILLS/$skill"

  if [ ! -d "$FROM" ]; then
    echo "Предупреждение: исходная папка $FROM не найдена."
    continue
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] Скилл $skill -> $DEST"
    continue
  fi

  mkdir -p "$TARGET_SKILLS"
  rm -rf "$DEST"
  cp -R "$FROM" "$DEST"
  echo "Скилл '$skill' установлен в $DEST"
done

if [ -f "./rules/AGENTS.md" ]; then
  if [ "$DRY_RUN" = true ]; then
    echo "[dry-run] Правила AGENTS.md -> $TARGET_RULES/AGENTS.md"
  else
    mkdir -p "$TARGET_RULES"
    cp "./rules/AGENTS.md" "$TARGET_RULES/AGENTS.md"
    echo "Правила 'AGENTS.md' установлены в $TARGET_RULES/AGENTS.md"
  fi
fi

echo ""
if [ "$DRY_RUN" = true ]; then
  echo "Режим DryRun: ничего не изменено."
else
  echo "Установка завершена! Скиллы активируются в новой сессии Antigravity."
fi
