# Lazygit

Lazygit is the optional keyboard-first Git interface for the local Ghostty
workflow. It remains a separate tool: it does not configure Git, Vim, tmux
or the shell.

## Why it is opt-in

The configuration is managed, but installation is deliberately explicit.
Lazygit is available directly only in newer Debian and Ubuntu repositories,
while Fedora, RHEL and openSUSE commonly require additional repositories. The
playbook does not silently trust or enable those sources.

Install it with a method appropriate to the host, for example on macOS:

```bash
brew install lazygit
```

Then deploy:

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags lazygit --check --diff
ansible-playbook playbooks/dotfiles.yml --tags lazygit
```

The role fails clearly when `lazygit` is unavailable. It never runs in the
default play because it carries the `never` tag.

## XDG layout

```text
configs/lazygit/config.yml
  → $XDG_CONFIG_HOME/lazygit/config.yml
```

The normal fallback is `~/.config/lazygit/config.yml`. If a custom
`XDG_CONFIG_HOME` is selected in Ansible, export the same value in the
interactive shell that launches Lazygit.

## Deliberate configuration

Only behavior with a concrete workflow benefit is overridden:

- mouse capture is disabled, preserving normal terminal selection;
- four lines of scroll context make long lists calmer to navigate;
- random tips and introductory popups are hidden;
- Nerd Font 3 icons match the configured Ghostty font;
- the `vim` editor preset opens files and line locations consistently;
- self-update prompts are disabled because installation owns upgrades.

No color theme is imposed. Lazygit's own UI and Ghostty's palette remain
responsible for presentation. No custom clipboard command is added, avoiding
non-portable `base64` flags and tmux passthrough requirements.

Default Lazygit keys already follow the intended Vim-like workflow:
`h/j/k/l` move between panels and items, `/` searches, `n` and `N` repeat
searches, `Space` selects, `Enter` opens and `e` edits in Vim.

## Validation

Check the executable and resolved directory:

```bash
lazygit --version
lazygit --print-config-dir
```

The directory should be `$XDG_CONFIG_HOME/lazygit`. Open a disposable
repository and verify that `e` launches Vim, pointer dragging selects
terminal text and no update prompt appears.

## Rollback

Revert the repository configuration and rerun the opt-in role. The role copies
a real file and refuses to replace an unmanaged symlink.

## Upstream documentation

- [Lazygit installation](https://github.com/jesseduffield/lazygit#installation)
- [Lazygit configuration](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md)
