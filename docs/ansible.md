# Ansible deployment

Ansible deploys the portable configuration from `configs/` into the target
user's XDG configuration directory.

## Layout

```text
ansible/
├── ansible.cfg
├── inventory/
│   ├── local.yml
│   └── remote.example.yml
├── playbooks/
│   └── dotfiles.yml
├── roles/
│   ├── ghostty/
│   ├── lazygit/
│   ├── linux_packages/
│   ├── tmux/
│   └── vim/
├── values.yml
└── values.example.yml
```

## Local deployment

Run from `ansible/` so `ansible.cfg` and the local inventory are discovered:

```bash
ansible-playbook playbooks/dotfiles.yml --syntax-check
ansible-playbook playbooks/dotfiles.yml --check --diff
ansible-playbook playbooks/dotfiles.yml
```

The default play deploys Vim and tmux. Ghostty and Lazygit must be selected
explicitly:

```bash
ansible-playbook playbooks/dotfiles.yml --tags ghostty
ansible-playbook playbooks/dotfiles.yml --tags lazygit
```

## Remote deployment

```bash
cp inventory/remote.example.yml inventory/remote.yml

ansible-playbook \
  -i inventory/remote.yml \
  playbooks/dotfiles.yml \
  --limit workstation \
  --ask-become-pass
```

The inventory copy is ignored by Git. Configuration sources stay on the
controller; Ansible copies them to the selected host.

## Linux packages

| Family | Vim | tmux |
| --- | --- | --- |
| Debian | `vim` | `tmux` |
| Red Hat | `vim-enhanced` | `tmux` |
| SUSE | `vim` | `tmux` |

Package tasks use privilege escalation by default. Disable it only when the
target manages these packages separately.

## Tags

| Component | Default run | Explicit selection |
| --- | --- | --- |
| Vim | Yes | `--tags vim` |
| tmux | Yes | `--tags tmux` |
| Lazygit | No | `--tags lazygit` |
| Ghostty | No | `--tags ghostty` |

## Values

`values.yml` contains:

- the optional XDG configuration root override;
- directory and file modes;
- Linux package names and privilege escalation;
- application executable paths;
- pinned Nord repositories and revisions for Vim and tmux.

Create an ignored override only for machine-specific values:

```bash
cp values.example.yml values.local.yml
ansible-playbook playbooks/dotfiles.yml -e @values.local.yml
```

## XDG destination

The destination is resolved in this order:

1. `deployment.xdg_config_home` from merged values;
2. the target's `XDG_CONFIG_HOME`;
3. the target's `~/.config` directory.

Export the same `XDG_CONFIG_HOME` in interactive shells when using a custom
path.

## Themes

The Vim and tmux roles clone Nord directly on the managed host at the exact
commits recorded in `values.yml`. Existing clean checkouts are updated to
those revisions; dirty theme checkouts are not overwritten forcibly.

## Safety and validation

Roles refuse to replace symbolic-link destination directories. They preserve
the optional Ghostty and tmux `90-local.conf` files and validate changed
configuration with:

- `ghostty +show-config --changes-only`;
- Vim startup plus native XDG discovery;
- an isolated tmux server lifecycle;
- Lazygit's configuration resolution.

A second normal run should report `changed=0`.
