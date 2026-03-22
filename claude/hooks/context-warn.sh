#!/bin/bash
# UserPromptSubmit hook — warn when context exceeds 75%

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
CONTEXT_FILE="/tmp/claude-context-${SESSION_ID}.txt"
THRESHOLD=75

if [ ! -f "$CONTEXT_FILE" ]; then
  exit 0
fi

USED=$(cat "$CONTEXT_FILE" 2>/dev/null || echo "0")

if [ "$USED" -ge "$THRESHOLD" ]; then
  echo "⚠️  Context at ${USED}%. Consider running /compact at a good stopping point."
fi

# Always exit 0 — this is a warning only, never block
exit 0
