# Architecture

## Goal

This repository keeps one small terminal environment consistent between a
local Mac and remote Linux hosts:

```text
macOS
└── Ghostty
    ├── Vim
    ├── Lazygit
    └── SSH
        └── Linux server
            └── tmux
                ├── Vim
                ├── operational tools
                └── persistent sessions
```

Ghostty owns the local terminal interface. tmux owns persistence after an SSH
connection. Vim is the only managed editor and is shared across both systems.

## Responsibility boundaries

| Concern | Local macOS | Remote Linux |
| --- | --- | --- |
| Terminal rendering | Ghostty | Forwarded through SSH |
| Windows, tabs and local splits | Ghostty | Not applicable |
| Persistent sessions | Optional tmux | tmux |
| Text editing | Vim | Vim inside tmux |
| Git terminal UI | Optional Lazygit | Optional |
| Connection transport | SSH launched from Ghostty | SSH server |

Bindings remain inside their layer: Ghostty controls native splits, tmux
controls remote panes and Vim controls editing.

## Configuration model

Repository sources use visible, application-oriented paths:

```text
configs/ghostty/config
configs/ghostty/conf.d/*.conf
configs/tmux/tmux.conf
configs/tmux/conf.d/*.conf
configs/vim/vimrc
configs/vim/config/*.vim
configs/lazygit/config.yml
```

Ansible maps each directory into the target user's XDG root. With no explicit
override this is `~/.config`.

```text
configs/ghostty/ → $XDG_CONFIG_HOME/ghostty/
configs/tmux/    → $XDG_CONFIG_HOME/tmux/
configs/vim/     → $XDG_CONFIG_HOME/vim/
configs/lazygit/ → $XDG_CONFIG_HOME/lazygit/
```

The main Ghostty, tmux and Vim entrypoints load ordered modules. Optional
machine-specific settings live in `90-local.conf` where supported and are not
tracked.

## Deployment model

Vim and tmux run in the default play. Ghostty and Lazygit use Ansible's
`never` tag and must be selected explicitly. Linux targets install Vim and
tmux through their native package managers; macOS package installation remains
explicit.

Vim and tmux use the Nord themes already present in the active configuration.
Ansible clones them at pinned revisions so a deployment does not silently
change when upstream branches move.

## Failure model

- Closing Ghostty ends local processes that do not own persistence.
- Losing SSH must not terminate work inside remote tmux.
- A malformed configuration is rejected by native validation after deployment.
- Existing symbolic-link configuration directories are never replaced
  implicitly.
- Local overrides and secrets remain outside the repository.
