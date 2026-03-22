#!/bin/bash

# PreToolUse hook — Block dangerous operations via allowlists
# Exit 0 = allow
# Exit 2 = block (Claude stops and receives message as error)

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# ─────────────────────────────────────────
# Rule 1: kubectl — allowlist read-only operations only
# ─────────────────────────────────────────
KUBECTL_ALLOWED='get|describe|logs|top|explain|diff|version|cluster-info|config view|config get-contexts|config current-context|api-resources|api-versions|events'

if echo "$COMMAND" | grep -qE 'kubectl\s+'; then
  if ! echo "$COMMAND" | grep -qE "kubectl\s+($KUBECTL_ALLOWED)"; then
    echo "🚨 BLOCKED: kubectl write operation must be run manually."
    echo ""
    echo "Command: $COMMAND"
    echo ""
    echo "Allowed read-only operations:"
    echo "  get, describe, logs, top, explain, diff, version,"
    echo "  cluster-info, config view/get-contexts, api-resources, events"
    exit 2
  fi
fi

# ─────────────────────────────────────────
# Rule 2: aws — allowlist read-only operations only
# ─────────────────────────────────────────
AWS_ALLOWED='describe|list|get|show|help|generate-cli-skeleton|wait'

if echo "$COMMAND" | grep -qE 'aws\s+'; then
  if ! echo "$COMMAND" | grep -qE "aws\s+[a-z0-9-]+\s+($AWS_ALLOWED)"; then
    echo "🚨 BLOCKED: AWS write operation must be run manually."
    echo ""
    echo "Command: $COMMAND"
    echo ""
    echo "Allowed read-only operations:"
    echo "  describe-*, list-*, get-*, show-*"
    exit 2
  fi
fi

# ─────────────────────────────────────────
# Rule 3: helm — allowlist read-only operations only
# ─────────────────────────────────────────
HELM_ALLOWED='list|get|status|history|search|show|version|env|verify|lint|template|diff'

if echo "$COMMAND" | grep -qE 'helm\s+'; then
  if ! echo "$COMMAND" | grep -qE "helm\s+($HELM_ALLOWED)"; then
    echo "🚨 BLOCKED: helm write operation must be run manually."
    echo ""
    echo "Command: $COMMAND"
    echo ""
    echo "Allowed read-only operations:"
    echo "  list, get, status, history, search, show, version,"
    echo "  env, verify, lint, template, diff"
    exit 2
  fi
fi

# ─────────────────────────────────────────
# Rule 4: terraform — allowlist safe operations only
# ─────────────────────────────────────────
TERRAFORM_ALLOWED='init|plan|validate|fmt|show|output|state list|state show|providers|version|workspace list|workspace show|graph|force-unlock'

if echo "$COMMAND" | grep -qE 'terraform\s+'; then
  if ! echo "$COMMAND" | grep -qE "terraform\s+($TERRAFORM_ALLOWED)"; then
    echo "🚨 BLOCKED: terraform write operation must be run manually."
    echo ""
    echo "Command: $COMMAND"
    echo ""
    echo "Allowed safe operations:"
    echo "  init, plan, validate, fmt, show, output,"
    echo "  state list/show, providers, version, workspace list/show"
    exit 2
  fi
fi

# ─────────────────────────────────────────
# Rule 5: rm — allowlist safe targets only (no system paths, no -rf on ~)
# ─────────────────────────────────────────
DANGEROUS_PATHS='(^|\s)(/|/etc|/usr|/bin|/sbin|/lib|/boot|/sys|/proc|/dev|/root|/home)(\s|$)'

if echo "$COMMAND" | grep -qE 'rm\s+-[a-zA-Z]*rf?|rm\s+-[a-zA-Z]*f?r'; then
  if echo "$COMMAND" | grep -qE "$DANGEROUS_PATHS"; then
    echo "🚨 BLOCKED: rm -rf on a system path is not allowed."
    echo ""
    echo "Command: $COMMAND"
    exit 2
  fi
fi

# ─────────────────────────────────────────
# Rule 6: Pipe remote content directly to shell
# ─────────────────────────────────────────
if echo "$COMMAND" | grep -qE '(curl|wget).+\|\s*(bash|sh|zsh|fish)'; then
  echo "🚨 BLOCKED: Piping remote content directly to shell is a security risk."
  echo ""
  echo "Command: $COMMAND"
  echo ""
  echo "Download the script first, review it, then execute manually."
  exit 2
fi

# ─────────────────────────────────────────
# Rule 7: dd disk operations
# ─────────────────────────────────────────
if echo "$COMMAND" | grep -qE '^\s*dd\s+'; then
  echo "🚨 BLOCKED: dd is too dangerous to run automatically."
  echo ""
  echo "Command: $COMMAND"
  exit 2
fi

# All checks passed — allow
exit 0
