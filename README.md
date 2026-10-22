# onecommandsetup

One command sets up a Mac the way I use it:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/ekang7/onecommandsetup/main/install.sh)
```

Or from a clone: `./install.sh`. Takes a few minutes, mostly Homebrew downloads. Safe to re-run.

| What | Where it goes |
|---|---|
| Homebrew, tmux, jq, cliclick, skhd | `brew` |
| AltTab, Raycast, Codex CLI | `brew --cask` (skipped if already in /Applications) |
| Claude Code | native installer → `~/.local/bin` |
| `tmux/tmux.conf` | `~/.tmux.conf` (prefix is **Option-w**) |
| `bin/tmux4` | `~/.local/bin/tmux4`: `tmux4 NAME [DIR]` opens a 2x2 tmux grid with codex in each pane |
| `macos/capslock-option.plist` | Caps Lock → Option, applied now and at every login |
| `skhd/skhdrc` | `~/.config/skhd/skhdrc` + launchd service |
| Spotlight ⌘Space shortcut | disabled, so Raycast can use it |
| `claude/settings.json`, `statusline.sh` | `~/.claude/` + plugins ponytail, warp, swift-lsp |
| `codex/config.toml`, `codex/rules/` | `~/.codex/` + plugin ponytail |
| `skills/*/SKILL.md` | `~/.claude/skills/` and `~/.codex/skills/` |

Each step runs on its own, so one failure doesn't stop the rest. A report at the end lists what succeeded and what failed. Full output goes to `~/.dotfiles-install.log`. Any existing file it replaces is first backed up to `~/.dotfiles-backup/<timestamp>/`.

**After it runs** (macOS won't let a script do these):
1. Privacy & Security → Accessibility: enable skhd and AltTab (AltTab also needs Screen Recording).
2. Raycast onboarding → set hotkey ⌘Space.
3. Sign in: `claude`, and for Codex `codex login` (ChatGPT account) or `printenv OPENAI_API_KEY | codex login --with-api-key` (API key).

In Codex, invoke a skill with `$skill-name` (e.g. `$tdd-verification`). In Claude Code, use `/skill-name`.

Fork it? Set `DOTFILES_REPO=you/onecommandsetup` before running.
