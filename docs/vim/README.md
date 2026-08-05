# Vim

Vim is the managed editor for local macOS work and remote Linux sessions.

## Layout

```text
configs/vim/
├── vimrc
└── config/
    ├── 10-options.vim
    ├── 20-keymaps.vim
    ├── 30-autocmds.vim
    └── 50-theme.vim
```

`vimrc` loads Vim's modern defaults and then sources every file below
`config/` in alphabetical order. The destination is
`$XDG_CONFIG_HOME/vim`, normally `~/.config/vim`.

Vim 9.1 or newer is required for native XDG vimrc discovery. The Ansible role
refuses to deploy while `~/.vimrc` or `~/.vim/vimrc` exists because those
legacy paths take precedence.

## Behavior

- absolute and relative line numbers;
- current-line and sign-column highlighting;
- two-space indentation by default;
- four-space indentation for Python;
- literal tabs for Makefile recipes;
- smart-case incremental search with highlighted matches;
- horizontal splits below and vertical splits to the right;
- five lines of vertical scroll context;
- `Space` as leader;
- `Space+h` to clear search highlighting;
- true-color Nord theme.

The Nord theme is installed below
`pack/themes/start/nord-vim` at the pinned revision in `ansible/values.yml`.

## Deployment

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags vim --check --diff
ansible-playbook playbooks/dotfiles.yml --tags vim
```

On supported Linux families, the tag installs Vim through the native package
manager. macOS uses its existing Vim installation.

## Validation

Validate the repository source using the already installed Nord checkout:

```bash
XDG_CONFIG_HOME="$HOME/.config" \
vim -Nu "$PWD/../configs/vim/vimrc" -n -es -i NONE \
  -c 'if !empty(v:errmsg) | cquit 1 | endif' \
  -c 'qa!'
```

After deployment, verify native discovery interactively:

```vim
:echo $MYVIMRC
:set number? relativenumber? shiftwidth? termguicolors?
:colorscheme
```

`$MYVIMRC` must resolve to `$XDG_CONFIG_HOME/vim/vimrc` and the active color
scheme must be `nord`.
