# tmux

tmux owns persistent remote workspaces. Its configuration is intentionally
small: only implemented behavior is loaded, and empty placeholder modules are
not kept in the runtime path.

## Layout

```text
configs/tmux/
├── tmux.conf
└── conf.d/
    └── 10-server.conf
```

The entrypoint loads modules in numeric order. Additional modules should be
created and sourced only when their behavior is implemented.

## Deployment

tmux is included in a normal Ansible run:

```bash
cd ansible
ansible-playbook playbooks/dotfiles.yml --tags tmux
```

On remote hosts, select an SSH inventory with `-i`. Ansible deploys the files
to `$XDG_CONFIG_HOME/tmux`, or `~/.config/tmux` when XDG is unset.

On Debian, Red Hat and SUSE family Linux targets, the same `tmux` tag installs
the distribution package first. Package installation uses privilege
escalation; configuration deployment remains owned by the remote user.

## Server behavior

The current server module:

- retains 100,000 lines of pane history;
- starts window and pane indexes at one and closes numbering gaps;
- keeps the server alive without sessions;
- selects another session instead of detaching when possible;
- retains panes whose processes fail;
- names windows after the active command;
- refreshes status every five seconds;
- forwards focus events to applications;
- retains at most 50 internal copy buffers.

## Validation

When configuration changes, Ansible starts and stops an isolated tmux server
using the deployed configuration. For an interactive inspection:

```bash
tmux -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
tmux show-options -g
tmux show-window-options -g
```
