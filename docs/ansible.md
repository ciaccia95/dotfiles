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
│   ├── lazygit/
│   ├── linux_packages/
│   ├── nvim/
│   ├── tmux/
│   └── vim/
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

| Ansible OS family | Neovim | Vim | tmux |
| --- | --- | --- | --- |
| `Debian` | `neovim` | `vim` | `tmux` |
| `RedHat` | `neovim` | `vim-enhanced` | `tmux` |
| `Suse` | `neovim` | `vim` | `tmux` |

Installation uses `ansible.builtin.package`, which selects the backend from
gathered facts. Packages must be available in repositories enabled on the
target; a RHEL installation may require a suitable supplemental repository
before Neovim is available.

Package tasks use `become: true` by default. Use passwordless sudo or pass
`--ask-become-pass`. Override the setting through the values file when
privilege escalation is managed differently.

On non-Linux systems package tasks are skipped. Existing application checks
still ensure Neovim, Vim and tmux are available before configuration is
deployed.

Lazygit is not part of this package table. Current Debian, Red Hat and SUSE
releases require different native or third-party repository strategies, so the
repository does not silently enable external package sources or download
unverified binaries.

## Components and tags

| Component | Default run | Explicit selection |
| --- | --- | --- |
| Neovim package and config | Yes | `--tags nvim` |
| Vim package and config | Yes | `--tags vim` |
| tmux package and config | Yes | `--tags tmux` |
| Lazygit config | No (`never`) | `--tags lazygit` |
| Ghostty | No (`never`) | `--tags ghostty` |

Ghostty also checks that the target is macOS. Ghostty and Lazygit can never be
deployed by an untagged run, including with the default local inventory.

Examples:

```bash
# Neovim only, locally.
ansible-playbook playbooks/dotfiles.yml --tags nvim

# Vim only, locally or remotely.
ansible-playbook playbooks/dotfiles.yml --tags vim

# Neovim, Vim and tmux on one remote host.
ansible-playbook \
  -i inventory/remote.yml \
  playbooks/dotfiles.yml \
  --tags nvim,vim,tmux \
  --limit workstation

# Lazygit after installing its executable explicitly.
ansible-playbook playbooks/dotfiles.yml --tags lazygit

# Ghostty explicitly on a macOS target.
ansible-playbook playbooks/dotfiles.yml --tags ghostty
```

## Values and overrides

Parameters that commonly vary are centralized in `values.yml`:

- controller source root;
- optional explicit XDG configuration and state destinations;
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

## XDG destinations

Configuration destination is resolved independently for every managed host:

1. `deployment.xdg_config_home` from the merged values, when set;
2. the target's `XDG_CONFIG_HOME`, when exported;
3. the target's `~/.config` directory.

This keeps repository paths readable while respecting each target's XDG
environment.

Vim state uses the equivalent sequence for `deployment.xdg_state_home`,
`XDG_STATE_HOME` and `~/.local/state`. When overriding the state destination,
export the same `XDG_STATE_HOME` for interactive Vim sessions.

## Safety and validation

Roles refuse to replace a symbolic-link configuration directory implicitly.
Existing regular directories are updated in place. Application checks run
before deployment, and changed configurations trigger native validation:

- `ghostty +show-config --changes-only`;
- headless Neovim startup;
- Vim syntax and native XDG discovery;
- an isolated tmux server lifecycle.

The opt-in Lazygit role parses its YAML and asks Lazygit to resolve the
deployed configuration directory.

Use `--check --diff` before changing a new host. A second normal run should
finish with `changed=0`.
