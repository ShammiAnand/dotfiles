#!/bin/bash
set -e

RULES_DIR="$HOME/.config/ai-rules"
CURSOR_RULES="$HOME/.cursor/rules"
CLAUDE_RULES="$HOME/.claude/rules"

if [ ! -d "$RULES_DIR" ]; then
  echo "Error: $RULES_DIR does not exist. Clone/copy it first."
  exit 1
fi

mkdir -p "$CURSOR_RULES" "$CLAUDE_RULES"

for f in "$RULES_DIR"/*.md; do
  name=$(basename "$f" .md)

  # Cursor: .mdc symlinks
  ln -sf "$f" "$CURSOR_RULES/${name}.mdc"

  # Claude Code: .md symlinks
  ln -sf "$f" "$CLAUDE_RULES/${name}.md"
done

echo "Symlinks created:"
echo ""
echo "Cursor ($CURSOR_RULES):"
ls -1 "$CURSOR_RULES"/*.mdc 2>/dev/null | xargs -n1 basename
echo ""
echo "Claude Code ($CLAUDE_RULES):"
ls -1 "$CLAUDE_RULES"/*.md 2>/dev/null | xargs -n1 basename
