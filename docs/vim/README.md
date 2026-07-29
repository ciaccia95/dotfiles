# Vim

Vim is the fallback for the Neovim workflow without external plugins. It is
useful on minimal servers, for recovery work and whenever launching the full
Neovim environment is unnecessary.

## Baseline and XDG layout

The recommended minimum is Vim 9.1 with native XDG vimrc discovery.

```text
configs/vim/vimrc
  → $XDG_CONFIG_HOME/vim/vimrc

$XDG_STATE_HOME/vim/
├── swap/
├── undo/
└── viminfo
```

Fallbacks are `~/.config/vim/vimrc` and `~/.local/state/vim`.

Vim searches `~/.vimrc` and `~/.vim/vimrc` before its XDG path. The Ansible
role therefore refuses to continue when either legacy file exists, including a
symlink. Migration stays explicit and the active configuration is never
ambiguous.

## Deployment

Vim participates in the default playbook or can run alone:

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags vim --check --diff
ansible-playbook playbooks/dotfiles.yml --tags vim
```

On Linux, the same tag installs `vim` on Debian and SUSE families or
`vim-enhanced` on Red Hat family systems. macOS uses its existing Vim and never
invokes Homebrew automatically.

The role copies a real file, creates private state directories and validates
the minimum version, vimrc syntax and native XDG discovery. A distribution
repository that ships Vim older than 9.1 must be upgraded explicitly.

## Neovim parity

Vim intentionally shares the portable editing core:

- `Space` leader;
- four-space indentation;
- relative and absolute line numbers;
- dark terminal-owned palette without true-color overrides;
- smart-case incremental search;
- splits below and to the right;
- explicit system clipboard mappings;
- quickfix and buffer navigation;
- persistent undo, swap recovery and cursor restoration;
- ripgrep integration when `rg` is available;
- keyboard mappings for window navigation and resizing.

Recent Vim releases also load their bundled optional `hlyank` runtime package.
If it is unavailable, startup still succeeds and only yank highlighting is
omitted.

Vim does not emulate Neovim-only diagnostics, floating-window borders, Lua APIs
or the global status line. Those differences remain explicit instead of being
approximated with plugins.

## Keybindings

| Mapping | Action |
| --- | --- |
| `n`, `N` | Move to and center the next or previous search result |
| `Ctrl+d`, `Ctrl+u` | Scroll half a page and center |
| `Ctrl+h/j/k/l` | Move between Vim windows |
| `Ctrl+Arrow` | Resize the current window |
| `[b`, `]b` | Previous or next buffer |
| `[q`, `]q` | Previous or next quickfix item |
| `Space bd` | Delete the current buffer with confirmation |
| `Space co`, `Space cc` | Open or close quickfix |
| `Space w` | Write |
| `Space q` | Quit with confirmation |
| `Space x` | Write and quit |
| `Space y`, `Space Y` | Copy to the system clipboard |
| `Space p`, `Space P` | Paste from the system clipboard |
| `Space ul` | Toggle invisible characters |
| `Space uw` | Toggle line wrapping |
| `Escape` | Clear search highlighting |
| `Escape Escape` | Leave Vim terminal mode |

Ordinary `y`, `d`, `p` and `P` continue using internal Vim registers, matching
Neovim and remaining predictable over SSH.

## Validation

Validate the source directly with isolated XDG state:

```bash
vim_test_root="$(mktemp -d)"
mkdir -p "$vim_test_root/config/vim" "$vim_test_root/state"
cp configs/vim/vimrc "$vim_test_root/config/vim/vimrc"

XDG_CONFIG_HOME="$vim_test_root/config" \
XDG_STATE_HOME="$vim_test_root/state" \
vim --not-a-term -T dumb -n -i NONE -c 'qa!' </dev/null
```

Inspect the active file and important options interactively:

```vim
:echo $MYVIMRC
:set shiftwidth? relativenumber? clipboard? undodir? directory? viminfofile?
:map
:autocmd antonello
```

`$MYVIMRC` must resolve to `$XDG_CONFIG_HOME/vim/vimrc`.

## Rollback

The configuration and mutable state are independent:

```bash
vim_config_home="${XDG_CONFIG_HOME:-$HOME/.config}/vim"
vim_state_home="${XDG_STATE_HOME:-$HOME/.local/state}/vim"
```

Revert the repository change and rerun the playbook to restore an earlier
version. Ansible does not delete legacy files or mutable Vim state.

## Upstream documentation

- [Vim startup and XDG discovery](https://vimhelp.org/starting.txt.html)
- [Vim options](https://vimhelp.org/options.txt.html)
- [Vim mappings](https://vimhelp.org/map.txt.html)
