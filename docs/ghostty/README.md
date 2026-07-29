# Ghostty

Ghostty is the local macOS terminal layer. It owns native windows, tabs and
splits, launches local command-line tools, and provides the SSH entry point to
remote systems. Persistent remote work belongs to tmux.

## Supported baseline

The configuration is validated with:

- Ghostty 1.3.1 on macOS;
- `JetBrainsMono Nerd Font Mono`;
- Ghostty's built-in `Broadcast` theme.

The repository uses a complete built-in theme without palette overrides.
Typography and window geometry are exposed as Ansible values because they are
the settings most likely to vary between displays or machines.

## Source and generated file

```text
configs/ghostty/config.ghostty.j2
        │
        │ Ansible template + merged values
        ▼
$XDG_CONFIG_HOME/ghostty/config
```

The repository path is deliberately visible and does not mirror `~/.config`.
The generated `config` filename is supported by the validated Ghostty version.

The template is a concise runtime configuration, not an option catalogue.
Rationale and lifecycle notes live in this document instead of surrounding
every setting with large comment blocks.

## Deployment

Ghostty carries Ansible's special `never` tag. It is not part of an ordinary
playbook run and must be requested explicitly:

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags ghostty --check --diff
ansible-playbook playbooks/dotfiles.yml --tags ghostty
```

The role rejects non-macOS targets and symbolic-link destination directories.
It renders the template into the target user's XDG configuration root, removes
the repository's previous `conf.d` layout, and validates the result with:

```bash
ghostty +show-config --changes-only
```

## Values

Canonical values live in `ansible/values.yml`:

```yaml
ghostty:
  executable: /Applications/Ghostty.app/Contents/MacOS/ghostty
  theme: Broadcast
  font:
    family: JetBrainsMono Nerd Font Mono
    size: 15
  window:
    width: 120
    height: 36
    padding_x: 10
    padding_y: 8
  macos:
    icon: xray
```

To change only machine-specific leaves, copy the override example and load it
as extra vars:

```bash
cp values.example.yml values.local.yml
ansible-playbook \
  playbooks/dotfiles.yml \
  --tags ghostty \
  -e @values.local.yml
```

The override map is recursively merged. For example, changing only font size
does not require repeating the theme or window settings:

```yaml
---
dotfiles_overrides:
  ghostty:
    font:
      size: 16
...
```

`values.local.yml` is ignored by Git. It must not contain credentials or other
secrets.

## Configuration reference

### Typography

| Option | Default | Purpose |
| --- | --- | --- |
| `font-family` | `JetBrainsMono Nerd Font Mono` | Readable monospace family with glyphs used by terminal interfaces |
| `font-size` | `15` | Balanced size for a MacBook display |
| `font-feature` | `calt` | Keeps contextual alternates and programming ligatures enabled |
| `font-thicken` | `false` | Preserves the font's native stroke weight |

Bold and italic families are not pinned. Ghostty selects matching faces from
the configured family. Cell width and height adjustments are also left unset,
preserving the font's native metrics.

### Theme

| Option | Default | Purpose |
| --- | --- | --- |
| `theme` | `Broadcast` | Loads one coherent, built-in dark palette |

No `background`, `foreground`, `palette`, `cursor-*`, `selection-*` or
`minimum-contrast` values are added after the theme. Broadcast owns the entire
color system, including ANSI colors used by shells and terminal applications.

Ghostty renders ANSI colors but does not determine whether an `ls` entry is a
file, directory or symbolic link. That semantic mapping belongs to the listing
tool and `LS_COLORS`. Use `ls -l` when file type must be communicated without
color: directories begin with `d`, links with `l` and `->`, and regular files
with `-`.

### Window

| Option | Default | Purpose |
| --- | --- | --- |
| `window-width` | `120` | Initial width in terminal cells |
| `window-height` | `36` | Initial height in terminal cells |
| `window-padding-x` | `10` | Horizontal breathing room |
| `window-padding-y` | `8` | Vertical breathing room |
| `window-padding-balance` | `true` | Distributes unused cell-grid space evenly |
| `window-step-resize` | `false` | Uses normal pixel-based macOS resizing |
| `background-opacity` | `1` | Keeps contrast predictable |
| `background-blur` | `false` | Avoids unnecessary rendering work |
| `unfocused-split-opacity` | `1` | Keeps inactive split text fully readable |

Initial dimensions affect new windows. Padding affects newly created terminal
surfaces. Background opacity changes require a full Ghostty restart on macOS.

### macOS integration

| Option | Default | Purpose |
| --- | --- | --- |
| `macos-titlebar-style` | `transparent` | Extends the theme into the native title bar |
| `macos-titlebar-proxy-icon` | `hidden` | Removes the Finder-style path icon |
| `macos-window-buttons` | `visible` | Preserves native traffic-light controls |
| `macos-window-shadow` | `true` | Preserves normal window depth |
| `macos-dock-drop-behavior` | `new-tab` | Opens Dock-dropped paths in a new tab |
| `macos-hidden` | `never` | Keeps Ghostty in the Dock and application switcher |
| `macos-icon` | `xray` | Uses Ghostty's X-ray runtime icon |
| `quit-after-last-window-closed` | `true` | Exits after the final window closes |

The icon value affects runtime macOS surfaces, not the signed application
bundle. Title-bar changes apply to new windows. Hiding the proxy icon becomes
visible after Ghostty observes a working-directory change.

Closing the last window also ends local processes that do not own their own
persistence. Remote work that must survive disconnection belongs inside tmux.

### Shell integration

| Option | Default | Purpose |
| --- | --- | --- |
| `shell-integration` | `detect` | Detects the login shell and injects supported integration |

The shell command is intentionally unset, so Ghostty launches the user's
configured login shell. `PATH`, `EDITOR` and tool-specific environment
variables remain shell responsibilities.

Automatic integration provides working-directory inheritance, prompt
boundaries, prompt-aware close confirmation and better redraw behavior. A
manually started nested shell may require its own integration setup.

### Keybindings

The repository defines no custom Ghostty keybindings. Native defaults remain
available for windows, tabs, splits, search, clipboard, font size and the
command palette without competing with Neovim or tmux mappings.

Inspect the exact bindings supplied by the installed version:

```bash
ghostty +list-keybinds
ghostty +list-keybinds --default
```

## Daily operations

```bash
# Installed version.
ghostty --version

# Effective non-default configuration.
ghostty +show-config --changes-only

# Complete offline option reference.
ghostty +show-config --default --docs | less

# Available fonts, themes and bindings.
ghostty +list-fonts
ghostty +list-themes
ghostty +list-keybinds
```

Outside a Ghostty-launched shell on macOS, call the application executable
directly:

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty --version
```

Use `Command+Shift+,` to reload ordinary changes.

## Troubleshooting

### Configuration does not load

Run `ghostty +show-config --changes-only`. Confirm that `config` exists below
the active XDG configuration root and rerun the explicit Ansible tag.

### Font or Nerd Font symbols are missing

Check the exact family name:

```bash
ghostty +list-fonts | rg "JetBrainsMono Nerd Font Mono"
```

Font family names are not filenames and must match Ghostty's reported name.

### Theme is unavailable

Run `ghostty +list-themes | rg '^Broadcast'`. Theme names are case-sensitive
and depend on the installed Ghostty release.

### A change appears to do nothing

Reload the configuration first. Create a new window for initial geometry or
title-bar settings, and fully quit Ghostty for background-opacity changes.

## Upgrade checklist

1. Read the Ghostty release notes for renamed or removed options.
2. Confirm that `Broadcast` and the configured font remain available.
3. Run the Ansible check and deployment commands with `--tags ghostty`.
4. Inspect `ghostty +show-config --changes-only`.
5. Test reload, a new window, tabs, splits, clipboard and shell integration.
6. Update the supported baseline only after validation succeeds.
