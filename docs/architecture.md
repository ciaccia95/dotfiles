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

Each top-level tool directory is a GNU Stow package. Its internal paths mirror
the destination below the user's home directory:

```text
nvim/.config/nvim/init.lua
  └── ~/.config/nvim/init.lua
```

Packages are installed selectively. A macOS workstation needs Ghostty and
Neovim; a Linux server needs Neovim and tmux. With the repository stored in
`~/Projects/dotfiles`, commands must set the home directory as the target:

```bash
stow --target="$HOME" ghostty nvim
stow --target="$HOME" nvim tmux
```

Installation scripts may wrap these commands later, but Stow remains the
underlying linking mechanism. Scripts must be safe to run repeatedly and must
offer a preview or clear diagnostic when an existing file blocks a link.

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
may become separate Stow packages. Project-specific automation, infrastructure
templates and training material remain outside this repository.

## Current status

The directory layout and architectural responsibilities are established.
Ghostty, Neovim and tmux configuration files are currently scaffolds and will
be implemented incrementally.
