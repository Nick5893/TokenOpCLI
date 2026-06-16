# tokenop — the Token Op Arcade

Terminal games that auto-pop in a new window while your AI works, then clear themselves when it's done. You're feeding your AI tokens into the machine — might as well play a game while it loads.

A tiny **Claude Code spinner companion**: `dino`, `snake`, `pong`, `flappy` — all in your terminal.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Nick5893/TokenOpCLI/main/install.sh | sh
```

Once **tokenop.dev** is live, the prettier form works too:

```sh
curl -fsSL https://tokenop.dev/install.sh | sh
```

Or clone and run it locally:

```sh
git clone https://github.com/Nick5893/TokenOpCLI.git && cd TokenOpCLI && sh install.sh
```

The installer downloads the single-file `tokenop` to `~/.local/bin`, runs a self-test, and enables the auto-open hook. It's reversible (`tokenop disable`), and you can install without enabling via `TOKENOP_NO_ENABLE=1`, change the location with `TOKENOP_BIN_DIR=…`, or remove everything with `… /install.sh --uninstall`.

## Play

```sh
tokenop                 # open the game selector
tokenop play pong       # play a specific game (dino | snake | pong | flappy)
tokenop list            # list games
```

## Auto-open while Claude Code thinks

`tokenop enable` adds two hooks to `~/.claude/settings.json` (merge-safe — it touches nothing else):

- `UserPromptSubmit` → opens the configured game/selector in a new Terminal window
- `Stop` → closes that window when the turn finishes

```sh
tokenop enable                  # default: open on prompt, close on stop
tokenop enable --mode session   # open on prompt; leave the window open
tokenop set pong                # pin one game (or `tokenop set menu` for the selector)
tokenop disable                 # remove the hooks — settings otherwise untouched
tokenop status                  # what's enabled, high scores, window state
tokenop doctor                  # environment checks
```

You can also toggle auto-open from inside the selector window — press `d`.

## How it works / safety

- **One file, no dependencies.** `tokenop` is a single Python script (standard library only).
- **No network, no telemetry.** It never phones home. The only external calls are local `osascript` to open/close a Terminal window.
- **Reversible & scoped.** `tokenop disable` removes its hooks; your other Claude Code settings are never modified.
- **macOS + Terminal.app** (uses AppleScript/`osascript` for the window). Run `tokenop doctor` to check your setup.

## Requirements

- macOS with Terminal.app
- Python 3.8+
- Automation permission for Terminal (granted on first window open)

## Controls

| Game | Controls |
|------|----------|
| dino | `Space`/`↑` jump · `↓` duck |
| snake | arrows / `WASD` |
| pong | `↑`/`↓` move your paddle (vs CPU) |
| flappy | `Space`/`↑` flap |

All games: `p` pause · `q` quit.

## License

[MIT](LICENSE)
