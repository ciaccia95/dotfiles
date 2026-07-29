# Ansible deployment

Ansible is the only deployment layer for this repository. Configuration stays
in visible directories below `configs/`; roles place it in the target user's
XDG configuration directory.

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
│   ├── linux_packages/
│   ├── nvim/
│   └── tmux/
├── values.yml
└── values.example.yml
```

`values.yml` contains canonical defaults. Role defaults derive source and
destination paths from the merged values rather than duplicating machine
paths.

## Local deployment

Run commands from `ansible/` so `ansible.cfg` is discovered:

```bash
ansible-playbook playbooks/dotfiles.yml --syntax-check
ansible-playbook playbooks/dotfiles.yml --check --diff
ansible-playbook playbooks/dotfiles.yml
```

The configured default inventory is `inventory/local.yml`, which uses a local
connection without SSH.

## Remote deployment

Create an ignored inventory from the example:

```bash
cp inventory/remote.example.yml inventory/remote.yml
```

Replace the example address and user, then target it explicitly:

```bash
ansible-playbook \
  -i inventory/remote.yml \
  playbooks/dotfiles.yml \
  --limit workstation \
  --ask-become-pass
```

The playbook contains no local connection override. Modules run on the selected
host, while `copy` and `template` read configuration from the controller.
Configuration deployment remains per-user. Privilege escalation is scoped to
Linux package installation.

## Linux package installation

Before configuration, the `linux_packages` role installs the selected tools on
supported Linux families:

| Ansible OS family | Native package backend | Neovim package | tmux package |
| --- | --- | --- | --- |
| `Debian` | APT | `neovim` | `tmux` |
| `RedHat` | DNF/YUM | `neovim` | `tmux` |
| `Suse` | Zypper | `neovim` | `tmux` |

Installation uses `ansible.builtin.package`, which selects the backend from
gathered facts. Packages must be available in repositories enabled on the
target; a RHEL installation may require a suitable supplemental repository
before Neovim is available.

Package tasks use `become: true` by default. Use passwordless sudo or pass
`--ask-become-pass`. Override the setting through the values file when
privilege escalation is managed differently.

On non-Linux systems package tasks are skipped. Existing application checks
still ensure Neovim and tmux are available before configuration is deployed.

## Components and tags

| Component | Default run | Explicit selection |
| --- | --- | --- |
| Neovim package and config | Yes | `--tags nvim` |
| tmux package and config | Yes | `--tags tmux` |
| Ghostty | No (`never`) | `--tags ghostty` |

Ghostty also checks that the target is macOS. It can never be deployed by an
untagged run, including when the default local inventory is used.

Examples:

```bash
# Neovim only, locally.
ansible-playbook playbooks/dotfiles.yml --tags nvim

# Neovim and tmux on one remote host.
ansible-playbook \
  -i inventory/remote.yml \
  playbooks/dotfiles.yml \
  --tags nvim,tmux \
  --limit workstation

# Ghostty explicitly on a macOS target.
ansible-playbook playbooks/dotfiles.yml --tags ghostty
```

## Values and overrides

Parameters that commonly vary are centralized in `values.yml`:

- controller source root;
- optional explicit XDG destination;
- directory and file modes;
- Linux privilege escalation and per-family package names;
- executable paths;
- Ghostty theme, font, initial window size, padding and application icon.

For local overrides:

```bash
cp values.example.yml values.local.yml
ansible-playbook \
  playbooks/dotfiles.yml \
  --tags ghostty \
  -e @values.local.yml
```

`dotfiles_overrides` is recursively merged over `dotfiles_defaults`, so the
override file needs to contain only changed leaves. The file is ignored by Git.
It is configuration, not a secret store.

## XDG destination

The destination is resolved independently for every managed host:

1. `deployment.xdg_config_home` from the merged values, when set;
2. the target's `XDG_CONFIG_HOME`, when exported;
3. the target's `~/.config` directory.

This keeps repository paths readable while respecting each target's XDG
environment.

## Safety and validation

Roles refuse to replace a symbolic-link configuration directory implicitly.
Existing regular directories are updated in place. Application checks run
before deployment, and changed configurations trigger native validation:

- `ghostty +show-config --changes-only`;
- headless Neovim startup;
- an isolated tmux server lifecycle.

Use `--check --diff` before changing a new host. A second normal run should
finish with `changed=0`.
