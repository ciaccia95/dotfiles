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
| Remote workspace | tmux | Persistent Linux sessions that survive SSH disconnects |
| Deployment | Ansible | Package installation, XDG mapping and configuration validation |

```text
macOS
└── Ghostty
    ├── Neovim
    └── SSH
        └── Linux
            └── tmux
                ├── Neovim
                ├── operational tools
                └── long-running sessions
```

## Quick start

Run Ansible from its directory so the repository configuration and default
local inventory are discovered:

```bash
cd ansible

# Preview Neovim and tmux.
ansible-playbook playbooks/dotfiles.yml --check --diff

# Apply Neovim and tmux.
ansible-playbook playbooks/dotfiles.yml
```

Ghostty is intentionally opt-in and never runs as part of the default play:

```bash
ansible-playbook playbooks/dotfiles.yml --tags ghostty
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

On Linux, Ansible installs Neovim and tmux before deploying their
configuration. Debian, Red Hat and SUSE operating-system families are
supported through their native package managers. On non-Linux systems,
package installation is skipped.

Packages must be available in repositories enabled on the target. RHEL may
require a suitable supplemental repository for Neovim.

## Select components

| Command | Result |
| --- | --- |
| `ansible-playbook playbooks/dotfiles.yml` | Neovim and tmux |
| `ansible-playbook playbooks/dotfiles.yml --tags nvim` | Neovim package and configuration |
| `ansible-playbook playbooks/dotfiles.yml --tags tmux` | tmux package and configuration |
| `ansible-playbook playbooks/dotfiles.yml --tags ghostty` | Ghostty configuration on macOS |

Ghostty carries Ansible's special `never` tag. It runs only when `ghostty` is
requested explicitly.

## Values

Stable defaults live in [`ansible/values.yml`](ansible/values.yml). They cover:

- XDG destination and file modes;
- executable and Linux package names;
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
│   ├── nvim/
│   └── tmux/
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
```

If `XDG_CONFIG_HOME` is unset, Ansible uses `~/.config`.

## Documentation

- [Architecture](docs/architecture.md) — local and remote responsibility boundaries
- [Ansible](docs/ansible.md) — inventories, tags, values and deployment behavior
- [Ghostty](docs/ghostty/README.md) — complete terminal configuration reference
- [Neovim](docs/nvim/README.md) — editor behavior, mappings and validation
- [tmux](docs/tmux/README.md) — persistent server behavior and workflow

## Principles

- Keep local terminal and remote workspace responsibilities separate.
- Add options and plugins only for concrete needs.
- Make platform-specific behavior explicit.
- Keep secrets and machine-specific data outside version control.
- Preserve a useful Neovim core even without plugins or network access.

## License

Released under the [MIT License](LICENSE).
