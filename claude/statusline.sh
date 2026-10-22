#!/usr/bin/env bash
# Claude Code status line — two lines:
#   Line 1: model · effort/thinking | directory | git branch+state
#   Line 2: context-usage bar+% | cost | lines churn | 5h/7d rate limits
# Receives session JSON on stdin. Field names per:
# https://code.claude.com/docs/en/statusline
set -o pipefail

input=$(cat)

# --- one jq pass; join with unit-separator (\037) so EMPTY fields survive --
# (a whitespace IFS like tab/newline collapses empty fields and shifts columns)
IFS=$'\037' read -r MODEL EFFORT THINKING DIR USED CTXSIZE COST ADDED REMOVED RL5 RL7 OVER200 STYLE <<EOF
$(printf '%s' "$input" | jq -r '[
  (.model.display_name // "?"),
  (.effort.level // ""),
  (.thinking.enabled // false),
  (.workspace.current_dir // .cwd // "."),
  ((.context_window.used_percentage // 0) | floor),
  (.context_window.context_window_size // 0),
  (.cost.total_cost_usd // 0),
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0),
  ((.rate_limits.five_hour.used_percentage // -1) | floor),
  ((.rate_limits.seven_day.used_percentage // -1) | floor),
  (.exceeds_200k_tokens // false),
  (.output_style.name // "default")
] | map(tostring) | join("\u001f")')
EOF

# --- colors ---------------------------------------------------------------
R=$'\033[0m'; DIM=$'\033[2m'; BOLD=$'\033[1m'
GRAY=$'\033[90m'; CYAN=$'\033[36m'; BLUE=$'\033[34m'
GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; MAGENTA=$'\033[35m'

pct_color() { # echoes a color code for a 0-100 value
  local p=${1%.*}
  if   [ "$p" -ge 80 ]; then printf '%s' "$RED"
  elif [ "$p" -ge 50 ]; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

bar() { # bar <pct> -> 10-cell ▓/░ meter
  local pct=${1%.*} width=10 filled i out=""
  [ -z "$pct" ] && pct=0
  filled=$(( (pct * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  for ((i=0; i<width; i++)); do
    if [ "$i" -lt "$filled" ]; then out="${out}▓"; else out="${out}░"; fi
  done
  printf '%s' "$out"
}

human_ctx() { # 200000 -> 200k, 1000000 -> 1M
  case "$1" in
    1000000) printf '1M' ;;
    200000)  printf '200k' ;;
    0|"")    printf '' ;;
    *)       printf '%sk' "$(( $1 / 1000 ))" ;;
  esac
}

# --- line 1: identity & location -----------------------------------------
seg1="${BOLD}${MAGENTA}${MODEL}${R}"
[ -n "$EFFORT" ] && [ "$EFFORT" != "null" ] && seg1="${seg1} ${DIM}${EFFORT}${R}"
[ "$THINKING" = "true" ] && seg1="${seg1} ${DIM}🧠${R}"
[ "$STYLE" != "default" ] && seg1="${seg1} ${DIM}<${STYLE}>${R}"

seg_dir="${CYAN}${DIR##*/}${R}"

seg_git=""
if br=$(git -C "$DIR" rev-parse --abbrev-ref HEAD 2>/dev/null); then
  dirty=""
  [ -n "$(git -C "$DIR" status --porcelain 2>/dev/null)" ] && dirty="${YELLOW}*${R}"
  updown=""
  if counts=$(git -C "$DIR" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null); then
    behind=${counts%%	*}; ahead=${counts##*	}
    [ "${ahead:-0}" -gt 0 ] 2>/dev/null && updown="${updown} ${GREEN}↑${ahead}${R}"
    [ "${behind:-0}" -gt 0 ] 2>/dev/null && updown="${updown} ${RED}↓${behind}${R}"
  fi
  seg_git=" ${GRAY}│${R} ${BLUE}⎇ ${br}${R}${dirty}${updown}"
fi

line1="${seg1} ${GRAY}│${R} ${seg_dir}${seg_git}"

# --- line 2: live metrics -------------------------------------------------
cc=$(pct_color "$USED")
ctxwin=$(human_ctx "$CTXSIZE")
ctx_label="${USED}%"
[ -n "$ctxwin" ] && ctx_label="${USED}% of ${ctxwin}"
warn=""
[ "$OVER200" = "true" ] && warn=" ${RED}⚠200k${R}"
seg_ctx="${DIM}ctx${R} ${cc}$(bar "$USED")${R} ${cc}${ctx_label}${R}${warn}"

# cost: 2dp, dim under 1 dollar
costf=$(printf '%.2f' "$COST" 2>/dev/null || printf '0.00')
seg_cost="${GRAY}│${R} ${GREEN}\$${costf}${R}"

seg_churn=""
if [ "${ADDED:-0}" -gt 0 ] 2>/dev/null || [ "${REMOVED:-0}" -gt 0 ] 2>/dev/null; then
  seg_churn=" ${GRAY}│${R} ${GREEN}+${ADDED}${R}${DIM}/${R}${RED}-${REMOVED}${R}"
fi

seg_rl=""
if [ "${RL5:-(-1)}" -ge 0 ] 2>/dev/null; then
  c5=$(pct_color "$RL5"); seg_rl=" ${GRAY}│${R} ${DIM}5h${R} ${c5}${RL5}%${R}"
  if [ "${RL7:-(-1)}" -ge 0 ] 2>/dev/null; then
    c7=$(pct_color "$RL7"); seg_rl="${seg_rl} ${DIM}7d${R} ${c7}${RL7}%${R}"
  fi
fi

line2="${seg_ctx} ${seg_cost}${seg_churn}${seg_rl}"

printf '%s\n%s' "$line1" "$line2"
