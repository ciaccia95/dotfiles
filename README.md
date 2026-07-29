# dotfiles

Reproducible development and operations environment built around Ghostty,
Neovim and tmux.

This repository contains version-controlled configuration for a local macOS
development environment and remote Linux operations environments. It is kept
intentionally small: tools and plugins are added only when they solve a
concrete problem.

## Architecture

```text
macOS
└── Ghostty
    ├── Neovim
    ├── lazygit
    ├── shell
    └── SSH
        └── Linux server
            └── tmux
                ├── Neovim
                ├── operational tools
                └── long-running sessions
```

Ghostty owns the local terminal experience. tmux owns persistent remote
workspaces and remains optional on macOS. Neovim configuration is shared
between macOS and Linux wherever possible.

See [Architecture](docs/architecture.md) for responsibilities, boundaries and
deployment decisions, and the [Ghostty guide](docs/ghostty/README.md) for the
complete terminal configuration reference.

## Principles

- Every non-obvious option has a documented purpose.
- Local and remote responsibilities remain separate.
- Configuration is reproducible and can be installed selectively.
- Secrets and environment-specific data are never committed.
- Platform-specific behavior is detected explicitly.
- Plugins are introduced only when they solve a concrete problem.

## Repository structure

```text
.
├── ghostty/   Ghostty configuration for macOS
├── nvim/      Shared Neovim configuration
├── tmux/      tmux configuration, primarily for remote Linux systems
├── docs/      Architecture and workflow documentation
└── scripts/   Installation and maintenance utilities
```

Each tool directory is a GNU Stow package whose contents mirror paths below
the user's home directory.

## Installation model

Packages are linked independently from the repository root. Ghostty is the
first implemented package:

```bash
stow --no --verbose --target="$HOME" ghostty
stow --target="$HOME" ghostty
```

Using an explicit target is required because this repository normally lives
under `~/Projects`, not directly under the home directory.

Machine-specific settings belong in ignored local files, not in the shared
packages.

## Project status

The repository structure and architecture are defined. Implementation follows
this order:

- [x] Ghostty
- [ ] Neovim core, without plugins
- [ ] Essential Neovim plugins
- [ ] tmux for remote workflows
- [ ] Installation and health-check scripts

## Security

Do not commit credentials, SSH keys, tokens, kubeconfig files, customer
configuration, company hostnames or shell history. See [.gitignore](.gitignore)
for the local-file conventions used by this repository.

## License

Released under the [MIT License](LICENSE).
