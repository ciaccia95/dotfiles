# tmux

tmux owns persistent terminal workspaces, especially after connecting to Linux
over SSH. It remains a multiplexer: shell, editor, terminal and infrastructure
tool configuration stay outside this component.

The base configuration is complete without plugins. TPM, tmux-resurrect and
tmux-continuum add persistence across server or machine restarts when installed.

## Baseline

- Recommended minimum: tmux 3.3a.
- Validated locally: tmux 3.7b on macOS.
- Supported terminals: Ghostty locally and through SSH.
- Supported shells: POSIX shell, Bash and Zsh.
- Supported targets: macOS and Linux.

The 3.3a baseline provides the modern `terminal-features` model and the options
used for terminal security and failed-pane retention. Distribution packages
older than this baseline must be upgraded before deploying the configuration.

Check the installed release:

```bash
tmux -V
```

## Layout

```text
configs/tmux/
├── tmux.conf
└── conf.d/
    ├── 10-server.conf
    ├── 20-terminal.conf
    ├── 30-input.conf
    ├── 40-sessions.conf
    ├── 50-windows.conf
    ├── 60-panes.conf
    ├── 70-copy-mode.conf
    ├── 80-status.conf
    └── 90-plugins.conf
```

`tmux.conf` contains only explicit, ordered `source-file -q` calls. Paths are
resolved relative to the entrypoint with tmux formats, so the loader works with
both the standard `~/.config` fallback and a custom `XDG_CONFIG_HOME`.

| Module | Responsibility |
| --- | --- |
| `10-server.conf` | History, numbering, server lifecycle and automatic names |
| `20-terminal.conf` | TERM, terminfo fallback, Ghostty features and focus |
| `30-input.conf` | Prefix, latency, mouse policy and reload |
| `40-sessions.conf` | Selection, creation, rename, detach and removal |
| `50-windows.conf` | Creation, navigation, rename and removal |
| `60-panes.conf` | Splits, navigation, resize, zoom and synchronized input |
| `70-copy-mode.conf` | Terminal selection, Vim copy mode and OSC 52 |
| `80-status.conf` | ANSI-only operational interface |
| `90-plugins.conf` | Optional TPM, resurrect and continuum integration |

## Deployment

### Ansible

tmux participates in the normal playbook or can be selected alone:

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags tmux --check --diff
ansible-playbook playbooks/dotfiles.yml --tags tmux
```

The role:

- installs tmux only on supported Linux families through `linux_packages`;
- never invokes Homebrew on macOS;
- fails clearly when the executable is unavailable;
- checks every source module;
- copies real files into the target XDG path;
- validates changes with an isolated tmux server.

On remote Linux:

```bash
ansible-playbook \
  -i inventory/remote.yml \
  playbooks/dotfiles.yml \
  --tags tmux \
  --limit workstation \
  --ask-become-pass
```

### Manual directory preparation

Ansible is preferred. For a manual inspection or installation:

```bash
tmux_config_home="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
mkdir -p "$tmux_config_home/conf.d"
cp configs/tmux/tmux.conf "$tmux_config_home/tmux.conf"
cp configs/tmux/conf.d/*.conf "$tmux_config_home/conf.d/"
```

The wildcard above copies files; it is not used by tmux to load modules.

## Design

### Server lifecycle

- windows and panes begin at index one;
- window indexes close gaps automatically;
- 100,000 history lines support long operational output;
- detached sessions remain alive;
- the server exits after its final session is destroyed;
- destroying the attached session switches to another session when available;
- panes remain visible only when their process fails;
- automatic window names follow the active command;
- a manual rename disables automatic naming for that window.

This avoids empty background servers while preserving work across SSH
disconnects.

### Terminal capabilities

Programs inside tmux receive `TERM=tmux-256color` when that terminfo entry
exists. Otherwise the configuration uses `screen-256color` as a conservative
fallback.

For Ghostty and its `xterm-256color` SSH fallback, `terminal-features` declares:

- RGB color;
- OSC 52 clipboard writes;
- focus reporting;
- hyperlinks;
- underline styles and underline color.

`terminal-overrides` is not used. Named feature classes are easier to audit and
are the modern tmux interface for capabilities not reported by terminfo.

Check the inner terminfo entry:

```bash
infocmp -x tmux-256color >/dev/null
```

If it is missing on a remote host, install an up-to-date ncurses terminfo
package or copy the entry without root:

```bash
infocmp -x tmux-256color |
  ssh workstation 'mkdir -p "$HOME/.terminfo" && tic -x -o "$HOME/.terminfo" -'
```

The automatic `screen-256color` fallback keeps the shell usable, but programs
may not discover true color, italics or undercurl until `tmux-256color` is
installed.

### Mouse, selection and scrollback

`mouse` is deliberately off. Ghostty receives normal pointer selection, so the
daily workflow stays native:

1. drag to select text;
2. press `Command+C`;
3. paste with `Command+V`.

Trade-off: terminal selection sees Ghostty's rendered scrollback, not the full
100,000-line tmux history. Use `Prefix+Enter` or `Prefix+[` for old output,
search and precise keyboard selection. Pane selection, resizing and status-line
interaction are keyboard-driven.

### Clipboard and OSC 52

`set-clipboard external` makes tmux write copied text to the outer terminal via
OSC 52 while refusing OSC 52 writes from arbitrary programs inside panes.
Copy-mode still creates a normal tmux paste buffer.

On tmux 3.7 and newer, `get-clipboard off` also ignores clipboard-read requests
from applications. Earlier supported releases did not expose that read path;
the option is applied quietly so the same configuration remains portable.

This is intentionally stricter than `set-clipboard on`:

- tmux copy mode may write the system clipboard;
- programs in panes cannot inject tmux buffers through OSC 52;
- no `pbcopy` dependency exists;
- the same path works from a remote tmux through SSH to local Ghostty.

Clipboard reads are a terminal security decision. The recommended Ghostty
settings are documented below.

### Prefix and keyboard policy

The standard `Ctrl+b` prefix is retained. All structural navigation remains
behind it, so unprefixed `Ctrl+h/j/k/l`, Escape and application mappings still
belong to shells, Neovim and other TUIs.

Lowercase directions select panes; uppercase directions resize them. Windows
use tmux's familiar `n`, `p` and numeric keys. Destructive operations require
confirmation.

### Status line

The status line uses ANSI names only: black, white, yellow and cyan. It defines
no RGB values and no independent theme.

It shows:

- session name;
- windows and their tmux flags;
- reverse-video active window;
- `PREFIX` while the prefix is active;
- `SYNC` while input synchronization is enabled;
- `ZOOM` while the active pane is zoomed;
- hostname;
- date and 24-hour time.

Important state uses text, contrast and bold attributes rather than red/green
alone. No battery, CPU, RAM, weather, public IP, username, icon font or
Powerline glyph is required.

## Ghostty requirements

This component does not change Ghostty. For the complete local and SSH
clipboard path, configure Ghostty itself with:

```ini
clipboard-write = allow
clipboard-read = deny
shell-integration-features = cursor,no-sudo,title,ssh-env,ssh-terminfo,path
```

- `clipboard-write=allow` accepts OSC 52 writes from tmux.
- `clipboard-read=deny` prevents remote clipboard queries.
- `ssh-terminfo` installs `xterm-ghostty` terminfo remotely when possible.
- `ssh-env` falls back to `xterm-256color` and propagates color metadata when
  terminfo installation fails.

Ghostty 1.2 or newer is required for the two SSH integration features. The
remote host needs `tic` for automatic terminfo installation. If its SSH server
does not accept the propagated environment variables, terminfo installation
still remains the preferred path.

## Copy mode

Enter copy mode with `Prefix+Enter`, then:

1. move with Vim keys;
2. press `v` to begin a character selection;
3. use `Ctrl+v` to toggle rectangular selection when needed;
4. press `y` or `Enter` to copy and leave copy mode.

Search uses `/` and `?`; repeat with `n` and `N`. `g` and `G` jump to the top
or bottom of history. `q` exits.

## Persistence plugins

The only declared plugins are:

```text
tmux-plugins/tpm
tmux-plugins/tmux-resurrect
tmux-plugins/tmux-continuum
```

No theme, status, metrics, clipboard or navigation plugin is used. tmux-yank is
unnecessary because native OSC 52 already preserves the tmux buffer and reaches
Ghostty locally or through SSH.

Install TPM in the XDG tmux directory:

```bash
tmux_config_home="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
git clone https://github.com/tmux-plugins/tpm \
  "$tmux_config_home/plugins/tpm"
```

Reload and install the declared plugins:

```text
Prefix+r
Prefix+I
```

tmux-resurrect saves with `Prefix+Ctrl+s` and restores with `Prefix+Ctrl+r`.
tmux-continuum saves every 15 minutes and restores when tmux starts.

Persistence restores sessions, windows, pane layouts, working directories and
supported commands. It cannot restore arbitrary in-memory process state,
network connections or unsaved editor buffers. Pane contents are not enabled
for capture, avoiding accidental persistence of sensitive terminal output.

TPM is loaded conditionally. Missing TPM or plugin directories never prevent
the base configuration from starting.

## Validation

### Complete isolated server

From the repository root:

```bash
tmux -L dotfiles-test \
  -f "$PWD/configs/tmux/tmux.conf" \
  start-server \; \
  show-options -g \; \
  show-options -s \; \
  kill-server
```

The `-L` socket isolates the test from normal sessions. The final
`kill-server` affects only that socket.

### Effective configuration

Inside a normal tmux session:

```bash
tmux show-options -g
tmux show-options -gw
tmux show-options -s
tmux list-keys -T prefix
tmux list-keys -T copy-mode-vi
tmux info
```

### True color, italics and undercurl

Confirm the outer capabilities:

```bash
tmux info | rg 'RGB:|Ms:|Smulx:|Setulc:'
```

Then run inside tmux:

```bash
printf '\033[38;2;255;120;80mTRUECOLOR\033[0m\n'
printf '\033[3mITALIC\033[0m  \033[4:3mUNDERCURL\033[4:0m\n'
```

Compare with the same commands directly in Ghostty. Missing `Smulx` or
`Setulc` indicates an incomplete `tmux-256color` entry.

### Local clipboard

1. Print recognizable text: `printf 'local-clipboard-test\n'`.
2. Select it with the pointer.
3. Copy with `Command+C`.
4. Paste into a safe text field with `Command+V`.
5. Repeat through copy mode with `Prefix+Enter`, `v`, movement and `y`.
6. Confirm the text is also present with `tmux show-buffer`.

### Clipboard through SSH

1. Connect from Ghostty to the Linux host.
2. Start remote tmux.
3. Confirm `tmux info | rg 'Ms:'` does not report `[missing]`.
4. Enter copy mode, select with `v`, and copy with `y`.
5. Paste into a local macOS text field with `Command+V`.
6. Keep `clipboard-read=deny` in Ghostty and do not test clipboard reads from
   the remote host.

### Copy mode and search

```bash
seq 1 200
```

Enter with `Prefix+Enter`, search for `150` with `/`, repeat with `n`, select
with `v`, and copy with `y`. Use `Prefix+[` as the familiar alternative entry.

### Reload

Press `Prefix+r`. The status message must say:

```text
tmux configuration reloaded
```

Then inspect messages and active options:

```bash
tmux show-messages
tmux show-options -g status-left
```

### Persistence

1. Install TPM and plugins with `Prefix+I`.
2. Create multiple named sessions, windows and panes.
3. Save manually with `Prefix+Ctrl+s`.
4. Stop only after verifying the save exists.
5. Start tmux and restore with `Prefix+Ctrl+r`.
6. Leave tmux running for at least 15 minutes and verify continuum creates a
   newer save.

### Window renumbering

Create three windows with `Prefix+c`, close the middle one with `Prefix+&`, and
run:

```bash
tmux list-windows -F '#I:#W'
```

Indexes should remain contiguous from one.

### Current directory inheritance

Change to a recognizable directory, create both split types, and run `pwd` in
each:

```text
Prefix+|
Prefix+-
```

Create a window with `Prefix+c`; every new shell should start in the original
active pane directory.

### Synchronized input

Create two disposable panes and press `Prefix+S`. The status line must display
`SYNC`. Type only harmless commands during this test, then press `Prefix+S`
again and verify the indicator disappears.

## Risks and trade-offs

- Mouse-off preserves native selection but requires copy mode for full tmux
  history and prevents mouse pane/status interactions.
- OSC 52 writes can replace the local clipboard. `external` limits writes to
  tmux itself, and Ghostty must deny reads separately.
- A 100,000-line history consumes more memory per pane than the default.
- Synchronized input sends keystrokes to every pane in the window; the visible
  `SYNC` label reduces but cannot eliminate operational risk.
- `screen-256color` is safe as a fallback but advertises fewer capabilities.
- Persistence plugins restore structure and commands, not live process memory.
- Failed panes remain visible intentionally and must be closed or respawned.

## Rollback

Before deployment, back up an existing configuration:

```bash
tmux_config_home="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
cp -R "$tmux_config_home" "${tmux_config_home}.backup"
```

To roll back repository changes, restore or revert the relevant Git revision,
then redeploy:

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags tmux
```

Most options and bindings update with `Prefix+r`. `default-terminal` affects
new panes and windows. A full `tmux kill-server` ends every session on that
socket; use it only after saving work and, when available, a resurrect snapshot.

## Shortcut reference

Every binding below is prefixed by `Ctrl+b` unless the context says copy mode.

| Scope | Key | Action |
| --- | --- | --- |
| Prefix | `Ctrl+b` | Send a literal `Ctrl+b` to the pane |
| Configuration | `r` | Reload all modules |
| Sessions | `s` | Open the session tree |
| Sessions | `N` | Create or switch to a named session in the current directory |
| Sessions | `$` | Rename the current session |
| Sessions | `d` | Detach the client |
| Sessions | `X` | Kill the current session with confirmation |
| Windows | `c` | Create a window in the current directory |
| Windows | `,` | Rename the current window and keep the manual name |
| Windows | `A` | Restore automatic naming for the current window |
| Windows | `n`, `p` | Select next or previous window |
| Windows | `Tab` | Select the last window |
| Windows | `w` | Open the window tree |
| Windows | `&` | Kill the current window with confirmation |
| Panes | `|`, `%` | Split side by side in the current directory |
| Panes | `-`, `"` | Split top and bottom in the current directory |
| Panes | `h`, `j`, `k`, `l` | Select pane left, down, up or right |
| Panes | `H`, `J`, `K`, `L` | Resize left, down, up or right by five cells |
| Panes | `z` | Toggle pane zoom |
| Panes | `q` | Display pane indexes |
| Panes | `x` | Kill the current pane with confirmation |
| Panes | `S` | Toggle synchronized input |
| Copy mode | `Enter`, `[` | Enter copy mode |
| Copy mode | `Page Up` | Enter copy mode one page above |
| Copy mode | `v` | Begin character selection |
| Copy mode | `Ctrl+v` | Toggle rectangular selection |
| Copy mode | `y`, `Enter` | Copy to tmux and OSC 52, then exit |
| Copy mode | `/`, `?` | Search forward or backward |
| Copy mode | `n`, `N` | Repeat search forward or reverse |
| Copy mode | `g`, `G` | Jump to top or bottom of history |
| Copy mode | `q` | Exit copy mode |
| TPM | `I` | Install declared plugins |
| TPM | `U` | Update plugins |
| TPM | `Alt+u` | Remove undeclared plugins |
| Resurrect | `Ctrl+s` | Save sessions manually |
| Resurrect | `Ctrl+r` | Restore sessions manually |

tmux's standard numeric window selection, command prompt and buffer bindings
remain available because the configuration does not clear the default key
tables.

## Upstream references

- [tmux manual](https://man.openbsd.org/tmux.1)
- [tmux Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started)
- [tmux clipboard guide](https://github.com/tmux/tmux/wiki/Clipboard)
- [TPM](https://github.com/tmux-plugins/tpm)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)
