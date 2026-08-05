# tmux

tmux provides persistent sessions for remote Linux work and can also be used
locally when terminal-level persistence is useful.

## Layout

```text
configs/tmux/
├── tmux.conf
└── conf.d/
    ├── 10-server.conf
    ├── 20-terminal.conf
    ├── 30-input.conf
    ├── 40-windows.conf
    ├── 50-status.conf
    └── 60-copy-mode.conf
```

`tmux.conf` loads the modules in order and then loads
`~/.config/tmux/conf.d/90-local.conf` when that untracked override exists.

| Module | Responsibility |
| --- | --- |
| `10-server.conf` | Escape latency, history, focus and server lifecycle |
| `20-terminal.conf` | `tmux-256color` and Ghostty RGB capability |
| `30-input.conf` | Mouse support and standard `Ctrl+b` prefix policy |
| `40-windows.conf` | One-based numbering, renumbering and automatic names |
| `50-status.conf` | Pinned Nord status theme |
| `60-copy-mode.conf` | Reserved for explicit copy-mode changes |

## Behavior

- Escape delay is 10 ms for responsive Vim use;
- pane history is limited to 10,000 lines;
- focus events are forwarded;
- the server exits when no sessions remain but survives client detach;
- `tmux-256color` is exposed to applications;
- RGB support is declared for Ghostty;
- mouse pane selection, resize and scroll are enabled;
- windows and panes start at index one;
- window indexes close gaps automatically;
- window names follow the active application;
- the Nord theme owns status-bar colors and formatting.

The theme is cloned into `themes/nord` at the exact revision configured in
`ansible/values.yml`.

## Deployment

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags tmux --check --diff
ansible-playbook playbooks/dotfiles.yml --tags tmux
```

On supported Linux families, the tag installs tmux before deployment. The
role removes obsolete module names from older repository layouts but preserves
`90-local.conf`.

## Validation

```bash
tmux -L dotfiles-test \
  -f "$PWD/configs/tmux/tmux.conf" \
  start-server \; \
  kill-server
```

The separate socket guarantees that validation cannot affect normal sessions.

Inside a normal session, inspect the effective configuration with:

```bash
tmux show-options -g
tmux show-options -s
tmux show-window-options -g
```
