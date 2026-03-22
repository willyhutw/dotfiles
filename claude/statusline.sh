#!/bin/bash

input=$(cat)
used=$(echo "$input" | jq '.context_window.used_percentage // 0')
remaining=$(echo "$input" | jq '.context_window.remaining_percentage // 100')
cost=$(echo "$input" | jq '.cost.total_cost_usd // 0')
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
session_id=$(echo "$input" | jq -r '.session_id // "default"')

# Write context % to session-specific temp file to avoid conflicts across multiple sessions
echo "$used" >"/tmp/claude-context-${session_id}.txt"

# Color based on usage
if [ "$used" -lt 50 ]; then
  color="\033[32m" # green
elif [ "$used" -lt 75 ]; then
  color="\033[33m" # yellow
else
  color="\033[31m" # red
fi

printf "${color}[${model}] Context: ${used}%% (${remaining}%% free)\033[0m | Cost: \$$(printf '%.4f' $cost)"
