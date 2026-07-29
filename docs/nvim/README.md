# Neovim

Neovim is the shared editor for local macOS development and remote Linux work.
The core configuration is intentionally useful without plugins, so editing,
recovery and navigation remain available on a new machine or minimal server.

## Supported baseline

The configuration is validated with Neovim 0.12.4. It relies on current core
features such as `winborder`, `vim.hl.on_yank()` and the modern diagnostic API.
Older Neovim releases are not supported implicitly; compatibility changes must
be deliberate and tested.

## File layout and load order

```text
configs/nvim/
├── init.lua
└── lua/
    └── antonello/
        ├── init.lua
        ├── options.lua
        ├── diagnostics.lua
        ├── keymaps.lua
        ├── autocmds.lua
        └── plugins/
            └── init.lua
```

1. `init.lua` defines the global and local leaders before any mappings load.
2. Unused external provider hosts are disabled before runtime plugins load.
3. `antonello/init.lua` loads options and enables filetype, indent and syntax
   support.
4. Diagnostics, keymaps and autocommands load after the editor defaults.
5. `plugins/init.lua` is reserved for the next implementation phase and is not
   required by the core.

## Installation

Deploy only Neovim from the Ansible directory:

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags nvim --check --diff
ansible-playbook playbooks/dotfiles.yml --tags nvim
```

This maps:

```text
configs/nvim/init.lua
  └── $XDG_CONFIG_HOME/nvim/init.lua
```

When XDG is unset on the managed host, Ansible uses `~/.config/nvim`. Pass a
remote inventory with `-i` to deploy the same source over SSH. The role refuses
to replace a symbolic-link configuration directory implicitly.

On Debian, Red Hat and SUSE family Linux targets, the `nvim` workflow installs
the configured `neovim` package first using the native package manager and
privilege escalation. On non-Linux targets it only verifies the existing
executable.

## Design decisions

### Plugin-free core

Options, navigation, quickfix, diagnostics and recovery use Neovim APIs only.
The editor must continue to start if the network is unavailable or a future
plugin manager fails.

Plugins will be introduced separately and only for capabilities that Neovim
core does not provide adequately.

Node, Python, Perl and Ruby provider hosts are disabled because the Lua core
does not use them. Language servers and external formatters do not depend on
these hosts. A provider should be re-enabled only when an adopted plugin
documents it as a requirement.

### Terminal-owned colors

`termguicolors` remains disabled and no Neovim colorscheme is selected. Syntax
highlight groups therefore use terminal ANSI colors supplied by Ghostty's
theme. This keeps the current core visually coherent without duplicating or
overriding the terminal palette.

Applications that require a dedicated true-color palette can revisit this
decision during the plugin phase.

### Local and remote clipboard

The unnamed Neovim registers remain internal to the editor. Normal `y`, `d`,
`p` and `P` therefore work consistently on macOS and over SSH.

Leader mappings access the `+` register explicitly when a system clipboard
provider is available:

- on macOS, Neovim normally uses `pbcopy` and `pbpaste`;
- on Linux, a graphical clipboard provider or a future OSC 52 setup may be
  required;
- missing remote clipboard support never changes ordinary editing registers.

### Recovery

Persistent undo and swap files are both enabled:

- undo history preserves completed edits between sessions;
- swap files can recover unsaved changes after a crash or lost remote session;
- Neovim stores them below `stdpath("state")`, outside project directories.

Permanent backup copies are disabled. Neovim's temporary write backup remains
enabled to protect the write operation itself.

## Options

### Interface

| Option | Value | Purpose |
| --- | --- | --- |
| `background` | `dark` | Selects highlight defaults intended for dark terminals |
| `termguicolors` | `false` | Uses the terminal-owned ANSI palette |
| `number`, `relativenumber` | `true` | Combines absolute position with efficient movement counts |
| `signcolumn` | `yes` | Prevents text shifting when signs appear |
| `cursorline` | `true` | Makes the active line easier to locate |
| `scrolloff`, `sidescrolloff` | `8` | Keeps context around the cursor |
| `laststatus` | `3` | Uses one global status line |
| `winborder` | `rounded` | Gives built-in and future floating windows a consistent border |

End-of-buffer tildes and the startup message are hidden to reduce visual noise.

### Editing

Four spaces are the portable default for indentation. Filetype indent scripts
and EditorConfig may override them for a project.

Lines do not wrap automatically. If wrapping is toggled for prose,
`linebreak` and `breakindent` preserve readable word and indentation boundaries.
Visual-block editing may move beyond the end of a short line through
`virtualedit=block`.

Invisible characters are disabled normally but have explicit glyphs ready for
the `<leader>ul` toggle.

### Search and completion

Search is case-insensitive until the pattern contains uppercase letters.
Incremental matches and persistent highlighting are enabled, while
substitutions are previewed in a split.

Command-line and insert completion use popup menus without selecting a
candidate automatically. The menu is capped at twelve entries.

When `rg` is installed, `:grep` uses ripgrep with Vim-compatible output and
smart-case matching. Neovim keeps its default grep implementation otherwise.

### Windows and responsiveness

New vertical splits open to the right and horizontal splits below. Screen
content remains stable when splits change, and resizing the outer UI equalizes
the current split layout.

The update interval is 250 milliseconds and mapping sequences time out after
400 milliseconds, keeping feedback responsive without making multi-key
mappings impractical.

## Keybindings

The leader and local leader are both `Space`. Every custom mapping has a
description visible through `:map`.

### Navigation and windows

| Mapping | Action |
| --- | --- |
| `n`, `N` | Move between search matches and center the result |
| `Ctrl-d`, `Ctrl-u` | Scroll half a page and center the cursor |
| `Ctrl-h/j/k/l` | Move focus between editor windows |
| `Ctrl-Arrow` | Resize the current editor window |

### Buffers and quickfix

| Mapping | Action |
| --- | --- |
| `[b`, `]b` | Select the previous or next buffer |
| `<leader>bd` | Delete the current buffer with modification protection |
| `[q`, `]q` | Select the previous or next quickfix item |
| `<leader>co`, `<leader>cc` | Open or close the quickfix list |

### Files and clipboard

| Mapping | Action |
| --- | --- |
| `<leader>w` | Write the current file |
| `<leader>q` | Quit the current window with confirmation |
| `<leader>x` | Write changes and quit |
| `<leader>y`, `<leader>Y` | Yank a selection or line to the system clipboard |
| `<leader>p`, `<leader>P` | Paste from the system clipboard |

### Diagnostics and display

| Mapping | Action |
| --- | --- |
| `[d`, `]d` | Previous or next diagnostic, provided by Neovim 0.12 |
| `<leader>dd` | Show the diagnostic under the cursor |
| `<leader>dq` | Send all diagnostics to quickfix |
| `<leader>ul` | Toggle invisible characters |
| `<leader>uw` | Toggle line wrapping |
| `Escape` | Clear search highlighting in Normal mode |
| `Escape Escape` | Leave Terminal mode |

In Visual mode, `<` and `>` preserve the selection after indentation.

## Autocommands

All autocommands belong to the `antonello` group, which is cleared before
redefinition so sourcing the configuration does not create duplicates.

| Event | Behavior |
| --- | --- |
| `TextYankPost` | Briefly highlights copied text |
| `FocusGained`, `TermClose`, `TermLeave` | Detects files changed by external tools |
| `VimResized` | Equalizes the current split layout |
| `BufReadPost` | Restores the last cursor position, except in Git message buffers |
| `FileType` | Adds a buffer-local `q` mapping to utility windows |
| `TermOpen` | Hides number and sign columns in terminal buffers |

Utility windows include help, manual pages, quickfix, health checks and LSP
information.

## Diagnostics

Diagnostics are sorted by severity and remain stable while typing. Neovim's
letter-based signs and underlines communicate severity without relying only on
color.

Virtual text and virtual lines are disabled to keep code uncluttered. Messages
are available through the cursor float, default diagnostic navigation and the
quickfix list. Floating diagnostics use rounded borders and display their
source.

This configures presentation only. LSP servers and external linters belong to
the later plugin and language-tooling phase.

## Validation

Load the repository configuration without using the installed home-directory
link:

```bash
XDG_CONFIG_HOME="$PWD/configs" \
  nvim --headless -i NONE -n \
  "+lua print('configuration loaded')" +qa
```

For an interactive health report:

```vim
:checkhealth
```

Useful inspection commands:

```vim
:set all
:map
:autocmd antonello
:lua vim.print(vim.diagnostic.config())
```

## Upgrade checklist

When Neovim is upgraded:

1. Read the release notes for removed or deprecated APIs.
2. Run the headless validation command.
3. Open `:checkhealth` and resolve new warnings.
4. Test filetype detection, syntax, swap recovery and persistent undo.
5. Test every custom mapping category.
6. Update the supported baseline only after the new version passes.

## Upstream documentation

- [Lua configuration guide](https://neovim.io/doc/user/lua-guide/)
- [Options](https://neovim.io/doc/user/options/)
- [Diagnostics](https://neovim.io/doc/user/diagnostic/)
- [Autocommands](https://neovim.io/doc/user/autocmd/)
