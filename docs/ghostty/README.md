# Ghostty

Ghostty is the local macOS terminal layer. It owns native windows, tabs and
splits and provides the SSH entrypoint to remote tmux sessions.

## Layout

```text
configs/ghostty/
├── config
└── conf.d/
    ├── 10-font.conf
    ├── 20-appearance.conf
    ├── 30-window.conf
    ├── 40-macos.conf
    ├── 50-terminal.conf
    └── 60-keybindings.conf
```

The entrypoint loads every module explicitly and then attempts to load the
untracked `conf.d/90-local.conf`. A missing local override is allowed.

## Configuration

| Area | Setting |
| --- | --- |
| Font | JetBrains Mono, 15 pt |
| Theme | Nord |
| Padding | 10 px horizontal, 8 px vertical, balanced |
| Window resizing | Pixel-based |
| macOS title bar | Transparent |
| macOS icon | X-Ray |
| Last window | Quit the application |
| Scrollback | 50 MiB per surface |
| Selection | Explicit copy with `Cmd+C` |
| Mouse | Hidden while typing |
| SSH integration | `ssh-env` compatibility fallback |

Custom keybindings use Vim directions:

| Binding | Action |
| --- | --- |
| `Cmd+Alt+h/j/k/l` | Move between splits |
| `Cmd+Ctrl+h/j/k/l` | Resize the focused split by 10 px |
| `Cmd+Alt+z` | Toggle split zoom |
| `Cmd+Alt+e` | Equalize splits |

## Deployment

Ghostty is opt-in and restricted to macOS targets:

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags ghostty --check --diff
ansible-playbook playbooks/dotfiles.yml --tags ghostty
```

The role copies the modular configuration, preserves `90-local.conf`, refuses
to replace an unmanaged symlink and validates changes with:

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty \
  +show-config --changes-only
```

Use `Command+Shift+,` to reload ordinary changes. Create a new window when a
window-level option does not update an existing surface.
