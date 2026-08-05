# dotfiles

A small, reproducible terminal environment for local macOS development and
persistent work on remote Linux systems.

The repository mirrors the portable parts of `~/.config` under `configs/`.
Ansible deploys real files to the target user's XDG configuration directory,
while host-specific `90-local.conf` overrides stay outside version control.

## Components

| Layer | Tool | Responsibility |
| --- | --- | --- |
| Local terminal | Ghostty | macOS windows, tabs, splits and SSH entrypoint |
| Editor | Vim | Shared editor configuration for macOS and Linux |
| Git interface | Lazygit | Optional keyboard-first Git workflow using Vim |
| Remote workspace | tmux | Persistent sessions across SSH disconnects |
| Deployment | Ansible | Package installation, XDG mapping and validation |

```text
macOS
└── Ghostty
    ├── Vim
    ├── Lazygit
    └── SSH
        └── Linux
            └── tmux
                ├── Vim
                └── long-running sessions
```

## Quick start

Run Ansible from its directory so the local inventory and configuration are
discovered:

```bash
cd ansible

# Preview or deploy Vim and tmux.
ansible-playbook playbooks/dotfiles.yml --check --diff
ansible-playbook playbooks/dotfiles.yml
```

Ghostty and Lazygit are opt-in:

```bash
ansible-playbook playbooks/dotfiles.yml --tags ghostty
ansible-playbook playbooks/dotfiles.yml --tags lazygit
```

Every changed configuration is validated with its native application. A
second deployment should finish with `changed=0`.

## Remote Linux

Create the ignored inventory and adjust its host and user:

```bash
cd ansible
cp inventory/remote.example.yml inventory/remote.yml
```

Then deploy Vim and tmux:

```bash
ansible-playbook \
  -i inventory/remote.yml \
  playbooks/dotfiles.yml \
  --limit workstation \
  --ask-become-pass
```

On Debian, Red Hat and SUSE families, Ansible installs Vim and tmux through the
native package manager before deploying their configuration.

## Select components

| Command | Result |
| --- | --- |
| `ansible-playbook playbooks/dotfiles.yml` | Vim and tmux |
| `ansible-playbook playbooks/dotfiles.yml --tags vim` | Vim package, Nord theme and configuration |
| `ansible-playbook playbooks/dotfiles.yml --tags tmux` | tmux package, Nord theme and configuration |
| `ansible-playbook playbooks/dotfiles.yml --tags lazygit` | Lazygit configuration after explicit installation |
| `ansible-playbook playbooks/dotfiles.yml --tags ghostty` | Ghostty configuration on macOS |

The Nord repositories used by Vim and tmux are pinned in
`ansible/values.yml` to the revisions validated in `~/.config`.

## Layout

```text
.
├── configs/
│   ├── ghostty/
│   ├── lazygit/
│   ├── tmux/
│   └── vim/
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   ├── roles/
│   └── values.yml
└── docs/
```

```text
configs/ghostty/ → $XDG_CONFIG_HOME/ghostty/
configs/lazygit/ → $XDG_CONFIG_HOME/lazygit/
configs/tmux/    → $XDG_CONFIG_HOME/tmux/
configs/vim/     → $XDG_CONFIG_HOME/vim/
```

If `XDG_CONFIG_HOME` is unset, Ansible uses `~/.config`.

The following optional files are deliberately local and are never copied into
the repository:

```text
~/.config/ghostty/conf.d/90-local.conf
~/.config/tmux/conf.d/90-local.conf
```

## Documentation

- [Architecture](docs/architecture.md)
- [Ansible](docs/ansible.md)
- [Ghostty](docs/ghostty/README.md)
- [Vim](docs/vim/README.md)
- [tmux](docs/tmux/README.md)
- [Lazygit](docs/lazygit/README.md)

## Principles

- Keep local terminal and remote workspace responsibilities separate.
- Add settings only for concrete needs.
- Keep secrets and machine-specific overrides outside version control.
- Pin external themes to known revisions.

## License

Released under the [MIT License](LICENSE).
