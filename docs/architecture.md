# Architecture

## Goals

This repository provides a small, reproducible environment for two related
workflows:

- local software development on macOS;
- persistent operational work on remote Linux systems.

It does not aim to be a general DevOps toolbox. Kubernetes manifests,
laboratories, customer automation and other project-specific assets belong in
separate repositories.

## System overview

```text
macOS
└── Ghostty
    ├── Neovim
    ├── lazygit
    ├── shell
    └── SSH
        └── Linux server
            └── tmux
                ├── persistent workspaces
                ├── Neovim
                ├── logs and monitoring
                ├── Kubernetes and containers
                └── operational sessions
```

The boundary is deliberate: Ghostty manages the local terminal interface,
while tmux provides persistence and session management after connecting to a
remote host.

## Local workflow

Ghostty is the terminal emulator on macOS. It owns native windows, tabs and
splits, and launches local tools such as Neovim, lazygit and the shell.

Neovim is the local editor. Its core configuration is shared with Linux so
that editing behavior remains familiar across environments.

tmux is optional locally. The default macOS workflow does not depend on it,
because using both Ghostty and tmux for the same local layout would duplicate
navigation and pane-management responsibilities.

## Remote workflow

Ghostty opens the SSH connection, but it does not own the remote workspace.
After connecting to Linux, tmux becomes the workspace manager.

tmux provides:

- sessions that survive SSH disconnections;
- named windows and repeatable layouts;
- keyboard-driven navigation and copy mode;
- a stable place for editors, logs, monitoring and long-running commands.

Neovim runs inside tmux when editing on the remote host. Operational tools run
in adjacent tmux windows or panes, so reconnecting restores the working
context.

## Responsibility boundaries

| Concern | Local macOS | Remote Linux |
| --- | --- | --- |
| Terminal rendering | Ghostty | Host terminal through SSH |
| Windows, tabs and local splits | Ghostty | Not applicable |
| Persistent sessions | Optional tmux | tmux |
| Remote windows and panes | Not applicable | tmux |
| Text editing | Neovim | Neovim inside tmux |
| Connection transport | SSH launched from Ghostty | SSH server |

Bindings should follow these boundaries. Ghostty bindings control local UI;
tmux bindings control only the remote workspace; Neovim bindings control
editing. A shortcut should not be assigned to multiple layers unless the
interaction is intentional and documented.

## Shared configuration

Neovim configuration is shared between macOS and Linux wherever behavior is
portable. Platform-specific behavior must be detected explicitly rather than
maintained in two mostly identical configurations.

Shared defaults must:

- work without machine-specific paths;
- degrade clearly when an optional executable is unavailable;
- avoid assumptions about customer or company infrastructure;
- keep secrets and host-specific values outside version control.

The shell and other cross-platform tools may adopt the same rule when their
packages are introduced.

## Deployment model

Configuration sources use visible, application-oriented paths:

```text
configs/nvim/init.lua
configs/ghostty/config.ghostty.j2
configs/tmux/tmux.conf
```

Ansible maps these sources into the target user's XDG configuration root:

```text
configs/nvim/    → $XDG_CONFIG_HOME/nvim/
configs/ghostty/ → $XDG_CONFIG_HOME/ghostty/
configs/tmux/    → $XDG_CONFIG_HOME/tmux/
```

When `XDG_CONFIG_HOME` is unset, the destination is `~/.config`. The source
always lives on the Ansible controller; the destination may be the controller
itself or a remote inventory host.

The default local inventory uses `ansible_connection: local`. Remote
inventories select SSH targets without changing the playbook. All roles can be
selected by tags. Neovim and tmux run by default; Ghostty carries the special
`never` tag and runs only when `--tags ghostty` is requested.

On Linux, a bootstrap role installs Neovim and tmux before deploying their
configuration. It supports the Debian, Red Hat and SUSE operating-system
families through Ansible's package abstraction and uses privilege escalation
only for package tasks. Non-Linux targets never execute package installation.

Settings that reasonably vary between machines live in
`ansible/values.yml`. An ignored override file is recursively merged over
those defaults, following the same default-values-plus-overrides model used by
Helm.

## Failure and recovery model

- Closing a local Ghostty window ends its local processes unless another tool
  owns their persistence.
- Losing an SSH connection must not terminate work running inside remote tmux.
- Reconnecting and attaching to the same tmux session restores the remote
  workspace.
- Configuration errors should remain isolated to the relevant package; a
  broken optional tool must not prevent the shell or SSH from working.

## Evolution rules

Configuration is added in layers: terminal, editor core, essential plugins,
then remote session management. New options require a clear purpose; new
plugins require a concrete use case.

General-purpose scripts, Git configuration, shell configuration and lazygit
may become separate managed components. Project-specific automation,
infrastructure templates and training material remain outside this repository.

## Current status

Ghostty, the plugin-free Neovim core, the tmux server foundation and their
Ansible deployment are implemented. The Neovim plugin layer and the remaining
tmux interaction modules will be introduced only for concrete workflows.
