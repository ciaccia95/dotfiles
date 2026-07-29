# Ghostty

Ghostty is the local terminal layer of this environment. It owns macOS windows,
tabs and local splits, launches local command-line tools, and provides the SSH
entry point to remote Linux systems. It does not replace tmux for persistent
remote work.

This guide documents every setting owned by the repository, how the files are
loaded, how to install and inspect the package, and which Ghostty defaults are
intentionally left unchanged.

## Supported baseline

The configuration has been validated with:

- Ghostty 1.3.1, stable channel;
- macOS with the Core Text font engine and Metal renderer;
- `JetBrainsMono Nerd Font Mono`;
- the built-in `Everforest Dark Hard` theme.

Ghostty's `config` filename is retained because it is supported by the current
version and keeps the existing Stow path stable. Recent Ghostty versions also
recognize the preferred `config.ghostty` filename.

## File layout and load order

```text
ghostty/.config/ghostty/
├── config
└── conf.d/
    ├── 10-font.conf
    ├── 20-theme.conf
    ├── 30-window.conf
    ├── 40-macos.conf
    ├── 50-keybindings.conf
    ├── 60-shell.conf
    ├── 90-local.conf.example
    └── 90-local.conf
```

| File | Responsibility |
| --- | --- |
| `config` | Entry point and ordered includes |
| `10-font.conf` | Font selection, OpenType features and rendering |
| `20-theme.conf` | Theme, contrast, cursor and selection colors |
| `30-window.conf` | Initial size, padding, resizing and background |
| `40-macos.conf` | Native macOS window, Dock and application behavior |
| `50-keybindings.conf` | Binding policy; no custom bindings at present |
| `60-shell.conf` | Shell detection and automatic integration |
| `90-local.conf.example` | Versioned examples for machine-specific settings |
| `90-local.conf` | Optional, ignored overrides for the current machine |

Included files are processed in the declared order. A value loaded later wins
when the same scalar option appears more than once. The optional `?` prefix on
`90-local.conf` prevents an error when the file does not exist.

The entry point uses the repeatable `config-file` option for every include.
Relative values are resolved from the file containing the directive, so the
package remains portable even when the repository is moved. The six shared
files are required; `?conf.d/90-local.conf` is the only optional include.

## Installation

From the repository root, preview the links before creating them:

```bash
stow --no --verbose --target="$HOME" ghostty
stow --target="$HOME" ghostty
```

The explicit target matters because the repository is stored below
`~/Projects`; Stow otherwise targets the repository's parent directory.

Stow stops when a real file already occupies a destination. Review and move any
existing Ghostty configuration before retrying. Do not use `stow --adopt`
without reviewing the resulting repository diff, because it can replace
versioned content with the destination's content.

The configured font must be visible to Ghostty:

```bash
ghostty +list-fonts | rg "JetBrainsMono Nerd Font Mono"
```

## Configuration reference

### Font and rendering

Source: `conf.d/10-font.conf`.

| Option | Value | Decision |
| --- | --- | --- |
| `font-family` | `JetBrainsMono Nerd Font Mono` | Uses JetBrains Mono plus Nerd Font glyphs required by terminal interfaces |
| `font-size` | `15` | Balances readability and usable space on a MacBook display |
| `font-feature` | `calt` | Keeps contextual alternates and programming ligatures enabled |
| `font-thicken` | `false` | Uses the font's native stroke weight instead of macOS-only artificial thickening |
| `adjust-cell-height` | unset | Preserves the font's native vertical cell metric |
| `adjust-cell-width` | unset | Preserves the font's native horizontal cell metric |

Bold, italic and bold-italic families are not pinned. Ghostty searches the
selected family for those variants and falls back to the regular face when
needed. Cell-height and cell-width adjustments are also left unset until a
measurable clipping or alignment problem appears.

`font-size` is expressed in points. Reloading it updates existing terminals
unless their size was already changed manually with a font-size shortcut.

### Theme and accessibility

Source: `conf.d/20-theme.conf`.

| Option | Value | Decision |
| --- | --- | --- |
| `theme` | `Everforest Dark Hard` | Uses the darkest built-in Everforest variant and its ANSI palette |
| `minimum-contrast` | `4.5` | Enforces the WCAG contrast ratio used as the AA target for normal text |
| `cursor-color` | `#d3c6aa` | Uses a bright neutral cursor that does not depend on red or green |
| `cursor-text` | `#1e2326` | Keeps the glyph beneath the cursor readable |
| `selection-foreground` | `#ffffff` | Gives selected text an explicit neutral foreground |
| `selection-background` | `#4f5b58` | Makes selection visible independently of syntax colors |

The theme supplies the normal background, foreground and palette. Explicit
cursor and selection colors override only those parts of the theme.

`minimum-contrast` may adjust low-contrast terminal colors toward black or
white. It does not modify emoji or images. Color must never be the only
carrier of state in Neovim, tmux, lazygit or other terminal applications.

### Window

Source: `conf.d/30-window.conf`.

| Option | Value | Decision |
| --- | --- | --- |
| `window-width` | `120` | Creates new windows 120 terminal cells wide |
| `window-height` | `36` | Creates new windows 36 terminal cells high |
| `window-padding-x` | `10` | Adds 10 points on the left and right |
| `window-padding-y` | `8` | Adds 8 points above and below the terminal grid |
| `window-padding-balance` | `true` | Distributes leftover cell-grid space across all edges |
| `window-step-resize` | `false` | Resizes in pixels instead of snapping to cell increments |
| `background-opacity` | `1` | Keeps the terminal fully opaque |
| `background-blur` | `false` | Avoids unnecessary blur and its rendering cost |
| `unfocused-split-opacity` | `1` | Prevents inactive Ghostty splits from being faded |

Both width and height must be present for the initial size to take effect. They
apply only when a new window is created; they do not resize existing windows,
tabs or splits. macOS can still restore a previously saved window size.

Padding is measured in points and changes apply to newly created terminals.
Balanced padding runs after the explicit padding and distributes space that
does not fit a complete terminal cell.

Changing `background-opacity` requires a complete Ghostty restart on macOS.
Blur has no visible purpose while opacity is `1`.

### macOS integration

Source: `conf.d/40-macos.conf`.

| Option | Value | Decision |
| --- | --- | --- |
| `macos-titlebar-style` | `transparent` | Keeps the native frame while extending the terminal background into the title bar |
| `macos-titlebar-proxy-icon` | `hidden` | Removes the current-directory proxy icon |
| `macos-window-buttons` | `visible` | Preserves the standard traffic-light controls |
| `quit-after-last-window-closed` | `true` | Exits Ghostty when its last window closes |
| `macos-hidden` | `never` | Keeps Ghostty in the Dock and application switcher |
| `macos-icon` | `xray` | Selects the official X-ray runtime icon variant |
| `macos-window-shadow` | `true` | Preserves the standard native window shadow |
| `macos-dock-drop-behavior` | `new-tab` | Opens Dock-dropped files or directories in a new tab when possible |

The runtime icon affects the Dock and application switcher, not the signed icon
stored in the application bundle. The proxy-icon setting becomes observable
after a working-directory change. Title-bar style and window-button changes
apply only to new windows.

Closing the last local window also terminates processes that do not own their
own persistence. Remote work that must survive disconnection belongs inside
tmux on the remote host.

### Keybindings

Source: `conf.d/50-keybindings.conf`.

No custom `keybind` entries are defined. Ghostty's macOS defaults are preserved
so the terminal follows native conventions and does not pre-empt planned
Neovim or tmux mappings.

The main effective defaults in Ghostty 1.3.1 are:

| Area | Binding | Action |
| --- | --- | --- |
| Configuration | `Command+,` | Open the configuration |
| Configuration | `Command+Shift+,` | Reload the configuration |
| Commands | `Command+Shift+P` | Toggle the command palette |
| Windows | `Command+N` | Create a window |
| Windows | `Command+W` | Close the focused surface |
| Windows | `Command+Enter` | Toggle fullscreen |
| Tabs | `Command+T` | Create a tab |
| Tabs | `Command+Shift+[` / `Command+Shift+]` | Select the previous or next tab |
| Tabs | `Command+1` through `Command+8` | Select a numbered tab |
| Tabs | `Command+9` | Select the last tab |
| Splits | `Command+D` | Create a split to the right |
| Splits | `Command+Shift+D` | Create a split below |
| Splits | `Command+[` / `Command+]` | Select the previous or next split |
| Splits | `Command+Option+Arrow` | Select a split by direction |
| Splits | `Command+Control+Arrow` | Resize a split by 10 pixels |
| Splits | `Command+Control+=` | Equalize split sizes |
| Splits | `Command+Shift+Enter` | Toggle focused-split zoom |
| Clipboard | `Command+C` / `Command+V` | Copy or paste |
| Search | `Command+F` | Start search |
| Search | `Command+G` / `Command+Shift+G` | Select the next or previous match |
| Scrollback | `Command+Up` / `Command+Down` | Jump between shell prompts |
| Font | `Command++` / `Command+-` | Increase or decrease font size |
| Font | `Command+0` | Reset font size |

The complete version-specific list is generated rather than copied into this
repository:

```bash
ghostty +list-keybinds
ghostty +list-keybinds --default
```

Custom bindings must be checked against macOS shortcuts, shell sequences,
Neovim mappings and the tmux prefix before they are added.

### Shell integration

Source: `conf.d/60-shell.conf`.

| Option | Value | Decision |
| --- | --- | --- |
| `command` | unset | Uses the user's configured login shell instead of a machine-specific path |
| `shell-integration` | `detect` | Detects a supported shell and injects the matching Ghostty integration |
| `shell-integration-features` | unset | Follows Ghostty's version-specific feature defaults |
| `env` | unset | Leaves `PATH`, `EDITOR` and tool variables to the shell configuration |

Automatic shell integration provides working-directory inheritance, prompt
boundaries, prompt-aware close confirmation and better redraw behavior for
complex prompts. On macOS, the initial shell is launched as a login shell.

The available feature switches in Ghostty 1.3.1 are `cursor`, `sudo`, `title`,
`ssh-env`, `ssh-terminfo` and `path`; prefixing a feature with `no-` disables
it. They remain unpinned here so a feature is changed only for a concrete
workflow requirement.

Automatic injection applies to the initial supported shell. Starting another
shell manually inside it can lose the integration unless that shell sources
Ghostty's integration script itself.

### Machine-specific overrides

`conf.d/90-local.conf.example` documents supported override patterns.
Create the ignored file only when the current Mac needs a different value:

```bash
cp ghostty/.config/ghostty/conf.d/90-local.conf.example \
  ghostty/.config/ghostty/conf.d/90-local.conf
```

Because it loads last, `90-local.conf` can override font size, initial window
dimensions, contrast, opacity, Option-key behavior or the shell command without
changing shared files.

| Example option | Intended local use |
| --- | --- |
| `font-size` | Adapt text size to a specific display |
| `window-width`, `window-height` | Adapt the initial grid to a specific screen |
| `minimum-contrast` | Compensate for a display with weak low-intensity colors |
| `background-opacity` | Enable verified, machine-specific transparency |
| `macos-option-as-alt` | Reserve one Option key for terminal Alt sequences |
| `command` | Launch a different shell on one machine |

The file is ignored to keep host details out of version control, but it is not
a secret store. Credentials, tokens and private keys do not belong there.

## Daily operations

Run these commands from a shell launched by Ghostty:

```bash
# Confirm the installed version.
ghostty --version

# Show only effective values that differ from Ghostty defaults.
ghostty +show-config --changes-only

# Read the complete offline option reference for the installed version.
ghostty +show-config --default --docs | less

# Inspect available fonts, themes and bindings.
ghostty +list-fonts
ghostty +list-themes
ghostty +list-keybinds
```

Shell integration normally makes the CLI available on `PATH`. From a shell
outside Ghostty on macOS, the application-bundle executable can be used
directly:

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty --version
```

Use `Command+Shift+,` to reload after an edit. Options with stricter lifecycle
rules are summarized below:

| Change | When it takes effect |
| --- | --- |
| Font size | On reload, except terminals manually zoomed |
| Initial width and height | New windows only |
| Window padding | New terminals only |
| Title-bar style and window buttons | New windows only |
| Proxy icon visibility | After the working directory changes |
| Background opacity on macOS | After fully restarting Ghostty |

## Troubleshooting

### Configuration does not load

Run `ghostty +show-config --changes-only` and inspect Ghostty's configuration
error window. Confirm that `config` exists below the active XDG configuration
directory and that relative `conf.d` paths remain beside it.

### Font falls back or symbols are missing

Confirm the exact family name with `ghostty +list-fonts`. Font family names are
not filenames, and spelling or style suffixes must match the value Ghostty
reports.

### Theme is unavailable

Run `ghostty +list-themes` and check the case-sensitive name. The configured
theme is bundled with the validated Ghostty version.

### Reload appears to do nothing

Check the lifecycle table above. Create a new window or terminal for
new-surface settings, and fully quit Ghostty for background-opacity changes on
macOS.

### Shell integration is missing

Confirm that the active shell is supported and initially launched by Ghostty.
For nested or renamed shells, follow Ghostty's manual integration instructions
instead of forcing unrelated environment variables in this package.

## Upgrade checklist

When Ghostty is upgraded:

1. Read the release notes between the old and new versions.
2. Run `ghostty +show-config --changes-only` and resolve every warning.
3. Confirm the font and theme still exist with their list commands.
4. Review default keybindings and shell-integration features for changes.
5. Test configuration reload, a new window, tabs, splits and shell-directory
   inheritance.
6. Update the supported baseline in this document after validation.

## Upstream documentation

- [Configuration format and file loading](https://ghostty.org/docs/config)
- [Configuration option reference](https://ghostty.org/docs/config/reference)
- [Keybindings](https://ghostty.org/docs/config/keybind)
- [Shell integration](https://ghostty.org/docs/features/shell-integration)
- [Ghostty 1.3.1 release notes](https://ghostty.org/docs/install/release-notes/1-3-1)
