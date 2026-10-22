#!/usr/bin/env bash
# One-shot macOS setup: tmux, skhd, AltTab, Raycast, Claude Code + Codex (config, plugins, skills).
#   bash <(curl -fsSL https://raw.githubusercontent.com/ekang7/onecommandsetup/main/install.sh)
# Safe to re-run. Every step runs even if an earlier one fails; a report prints at the end.
set -u

REPO="${DOTFILES_REPO:-ekang7/onecommandsetup}"
LOG="$HOME/.dotfiles-install.log"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_ENV_HINTS=1
export PATH="$HOME/.local/bin:$PATH"
G=$'\033[32m' R=$'\033[31m' Y=$'\033[33m' B=$'\033[1m' N=$'\033[0m'
OK=() FAILED=()
: >"$LOG"

# Run from a clone, or fetch the repo when piped in via curl.
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
if [ ! -d "$DIR/skills" ]; then
  DIR=$(mktemp -d)
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/main.tar.gz" | tar xz -C "$DIR" --strip-components 1 \
    || { echo "${R}Could not download $REPO${N}"; exit 1; }
fi

step() { # step <name> <cmd...>: run, log, record result, never abort
  local name=$1 t=$SECONDS; shift
  printf '%s→%s %-38s' "$B" "$N" "$name"
  echo "===== $name" >>"$LOG"
  if "$@" >>"$LOG" 2>&1 </dev/null; then
    OK+=("$name"); echo "${G}ok${N} ($((SECONDS - t))s)"
  else
    FAILED+=("$name"); echo "${R}FAILED${N} ($((SECONDS - t))s)"
  fi
}

put() { # put <src> <dst>: copy, backing up an existing different file first
  mkdir -p "$(dirname "$2")"
  if [ -e "$2" ] && ! cmp -s "$1" "$2"; then
    mkdir -p "$(dirname "$BACKUP/${2#"$HOME"/}")" && cp "$2" "$BACKUP/${2#"$HOME"/}"
  fi
  cp "$1" "$2"
}

profile_line() { grep -qsF "$1" ~/.zprofile || echo "$1" >>~/.zprofile; }

install_brew() {
  if ! command -v brew >/dev/null; then
    [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ] \
      || NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  else
    brew update || true # stale cask URLs 404; a fresh install is already current
  fi
  profile_line "eval \"\$($(command -v brew) shellenv)\""
}

cask() { # cask <token> <App.app>: skip if the app is already present
  [ -d "/Applications/$2" ] || brew install --cask "$1" || return 1
  open -a "${2%.app}"
}

skhd_service() {
  put "$DIR/skhd/skhdrc" ~/.config/skhd/skhdrc || return 1
  local bin; bin=$(command -v skhd) || return 1
  [ -f ~/Library/LaunchAgents/com.koekeishiya.skhd.plist ] || "$bin" --install-service || return 1
  "$bin" --restart-service 2>/dev/null || "$bin" --start-service
}

tmux_conf() { put "$DIR/tmux/tmux.conf" ~/.tmux.conf && { tmux source-file ~/.tmux.conf 2>/dev/null || true; }; }

raycast_hotkey() { # free Cmd+Space by disabling the Spotlight shortcut (id 64)
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
    '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>' || return 1
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
}

install_claude() {
  command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash || return 1
  profile_line 'export PATH="$HOME/.local/bin:$PATH"'
  command -v claude >/dev/null
}

claude_config() {
  put "$DIR/claude/settings.json" ~/.claude/settings.json && put "$DIR/claude/statusline.sh" ~/.claude/statusline.sh \
    && chmod +x ~/.claude/statusline.sh
}

claude_plugin() { # claude_plugin <plugin@marketplace> <owner/repo>
  claude plugin marketplace add "$2" || true # errors if already added; install below is the real check
  claude plugin install -y "$1"
}

codex_config() { put "$DIR/codex/config.toml" ~/.codex/config.toml && put "$DIR/codex/rules/default.rules" ~/.codex/rules/default.rules; }

codex_plugin() {
  codex plugin marketplace add DietrichGebert/ponytail || codex plugin marketplace upgrade ponytail || true
  codex plugin add ponytail@ponytail
}

skills() { # skills <dest dir>
  local s
  for s in "$DIR"/skills/*/; do put "$s/SKILL.md" "$1/$(basename "$s")/SKILL.md" || return 1; done
}

echo "${B}Setting up this Mac.${N} Full log: $LOG"
command -v brew >/dev/null || [ -x /opt/homebrew/bin/brew ] || {
  echo "Homebrew needs your password once:"
  sudo -v && { while sudo -n true; sleep 50; kill -0 $$ 2>/dev/null; do :; done 2>/dev/null & }
}

step "Homebrew"                     install_brew
step "tmux"                         brew install tmux
step "jq (statusline dependency)"   brew install jq
step "cliclick (skhd dependency)"   brew install cliclick
step "skhd"                         brew install koekeishiya/formulae/skhd
step "AltTab"                       cask alt-tab AltTab.app
step "Raycast"                      cask raycast Raycast.app
step "Codex CLI"                    bash -c 'command -v codex || brew install --cask codex'
step "Claude Code"                  install_claude
step "tmux config"                  tmux_conf
step "skhd config + service"        skhd_service
step "Cmd+Space freed for Raycast"  raycast_hotkey
step "Claude Code settings"         claude_config
step "Claude plugin: ponytail"      claude_plugin ponytail@ponytail DietrichGebert/ponytail
step "Claude plugin: warp"          claude_plugin warp@claude-code-warp warpdotdev/claude-code-warp
step "Claude plugin: swift-lsp"     claude_plugin swift-lsp@claude-plugins-official anthropics/claude-plugins-official
step "Codex config + rules"         codex_config
step "Codex plugin: ponytail"       codex_plugin
step "Skills for Claude Code"        skills ~/.claude/skills
step "Skills for Codex"              skills ~/.codex/skills

echo
echo "${B}===== Report ($((SECONDS / 60))m $((SECONDS % 60))s) =====${N}"
for s in "${OK[@]+"${OK[@]}"}"; do echo "  ${G}✔${N} $s"; done
for s in "${FAILED[@]+"${FAILED[@]}"}"; do echo "  ${R}✘${N} $s"; done
echo "  ${#OK[@]} succeeded, ${#FAILED[@]} failed."
[ ${#FAILED[@]} -gt 0 ] && echo "  Failure details: grep -A30 '===== <step name>' $LOG — then re-run this script."
[ -d "$BACKUP" ] && echo "  Replaced files backed up to $BACKUP"
cat <<EOF

${Y}${B}Manual steps (macOS won't let a script do these):${N}
  1. System Settings → Privacy & Security → Accessibility: enable ${B}skhd${N} and ${B}AltTab${N}
     (AltTab also needs Screen Recording). Then: skhd --restart-service
  2. Raycast: finish onboarding and set its hotkey to ⌘Space.
  3. Sign in: run ${B}claude${N}, and for Codex either ${B}codex login${N} or, with an API key,
     ${B}printenv OPENAI_API_KEY | codex login --with-api-key${N}
  4. Open a new terminal so PATH changes apply.
EOF
[ ${#FAILED[@]} -eq 0 ]
