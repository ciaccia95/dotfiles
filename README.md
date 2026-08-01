# dotfiles

A small, reproducible terminal environment for local macOS development and
persistent work on remote Linux systems.

Configuration sources stay easy to find under `configs/`. Ansible installs
them into the target user's XDG paths, locally or over SSH.

## At a glance

| Layer | Tool | Responsibility |
| --- | --- | --- |
| Local terminal | Ghostty | Native macOS windows, tabs, splits and SSH entrypoint |
| Editor | Neovim | Shared, plugin-free editing core for macOS and Linux |
| Fallback editor | Vim | XDG-native editing with Neovim-compatible behavior |
| Git interface | Lazygit | Optional keyboard-first local Git workflow |
| Remote workspace | tmux | Persistent Linux sessions that survive SSH disconnects |
| Deployment | Ansible | Package installation, XDG mapping and configuration validation |

```text
macOS
└── Ghostty
    ├── Neovim or Vim
    ├── Lazygit
    └── SSH
        └── Linux
            └── tmux
                ├── Neovim or Vim
                ├── operational tools
                └── long-running sessions
```

## Quick start

Run Ansible from its directory so the repository configuration and default
local inventory are discovered:

```bash
cd ansible

# Preview Neovim, Vim and tmux.
ansible-playbook playbooks/dotfiles.yml --check --diff

# Apply Neovim, Vim and tmux.
ansible-playbook playbooks/dotfiles.yml
```

Ghostty and Lazygit are intentionally opt-in:

```bash
ansible-playbook playbooks/dotfiles.yml --tags ghostty
ansible-playbook playbooks/dotfiles.yml --tags lazygit
```

Every changed configuration is validated with its native application. A second
run should finish with `changed=0`.

## Remote Linux

Create an ignored inventory from the example:

```bash
cd ansible
cp inventory/remote.example.yml inventory/remote.yml
```

Set the host and user, then run:

```bash
ansible-playbook \
  -i inventory/remote.yml \
  playbooks/dotfiles.yml \
  --limit workstation \
  --ask-become-pass
```

On Linux, Ansible installs Neovim, Vim and tmux before deploying their
configuration. Debian, Red Hat and SUSE operating-system families are
supported through their native package managers. On non-Linux systems,
package installation is skipped.

Packages must be available in repositories enabled on the target. RHEL may
require a suitable supplemental repository for Neovim.

## Select components

| Command | Result |
| --- | --- |
| `ansible-playbook playbooks/dotfiles.yml` | Neovim, Vim and tmux |
| `ansible-playbook playbooks/dotfiles.yml --tags nvim` | Neovim package and configuration |
| `ansible-playbook playbooks/dotfiles.yml --tags vim` | Vim package and XDG configuration |
| `ansible-playbook playbooks/dotfiles.yml --tags tmux` | tmux package and configuration |
| `ansible-playbook playbooks/dotfiles.yml --tags lazygit` | Lazygit configuration after explicit installation |
| `ansible-playbook playbooks/dotfiles.yml --tags ghostty` | Ghostty configuration on macOS |

Ghostty and Lazygit carry Ansible's special `never` tag. Lazygit is not
installed automatically because its native-package availability is not
consistent across the supported Linux releases.

## Values

Stable defaults live in [`ansible/values.yml`](ansible/values.yml). They cover:

- XDG configuration/state destinations and file modes;
- executable paths, the minimum Neovim version and Linux package names;
- Ghostty theme, font, initial window size, padding and icon.

Use an ignored override file for machine-specific values:

```bash
cd ansible
cp values.example.yml values.local.yml

ansible-playbook \
  playbooks/dotfiles.yml \
  --tags ghostty \
  -e @values.local.yml
```

Overrides are merged recursively, so only changed leaves need to be repeated.

## Repository

```text
.
├── configs/
│   ├── ghostty/
│   ├── lazygit/
│   ├── nvim/
│   ├── tmux/
│   └── vim/
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   ├── roles/
│   └── values.yml
└── docs/
```

The repository deliberately avoids mirroring hidden home-directory structures:

```text
configs/nvim/    → $XDG_CONFIG_HOME/nvim/
configs/ghostty/ → $XDG_CONFIG_HOME/ghostty/
configs/tmux/    → $XDG_CONFIG_HOME/tmux/
configs/vim/     → $XDG_CONFIG_HOME/vim/
configs/lazygit/ → $XDG_CONFIG_HOME/lazygit/
```

If `XDG_CONFIG_HOME` is unset, Ansible uses `~/.config`. Vim recovery state
uses `$XDG_STATE_HOME/vim`, falling back to `~/.local/state/vim`.

## Documentation

- [Architecture](docs/architecture.md) — local and remote responsibility boundaries
- [Ansible](docs/ansible.md) — inventories, tags, values and deployment behavior
- [Ghostty](docs/ghostty/README.md) — complete terminal configuration reference
- [Neovim](docs/nvim/README.md) — editor behavior, mappings and validation
- [Vim](docs/vim/README.md) — XDG fallback editor and Neovim parity
- [tmux](docs/tmux/README.md) — persistent server behavior and workflow
- [Lazygit](docs/lazygit/README.md) — opt-in Git interface and editor integration

## Principles

- Keep local terminal and remote workspace responsibilities separate.
- Add options and plugins only for concrete needs.
- Make platform-specific behavior explicit.
- Keep secrets and machine-specific data outside version control.
- Preserve useful Neovim and Vim cores without external plugins or network access.

## License

Released under the [MIT License](LICENSE).
