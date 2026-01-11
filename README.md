# Ubuntu Terminal Setup

A one-command bootstrap for a fresh Ubuntu machine (22.04/24.04), tailored for Python, DevOps, and AI development.

## Features

- **Shell**: Zsh + Zinit + Starship prompt + Autosuggestions/Syntax Highlighting
- **Editor**: 
  - **VS Code**: Python, Docker, Kubernetes, Terraform, AI extensions pre-installed. Settings tuned for formatting/linting.
  - **Neovim**: LazyVim starter with Mason LSP (Python, Bash, Terraform, Docker, etc.), Debugging, and Treesitter.
- **Tools**: Git (configured), Docker (official repo), standard CLI tools (ripgrep, fd, jq, fzf).
- **Safety**: Idempotent scripts, backup of existing configs, uninstall/rollback capable.

## Prerequisites

- Ubuntu 22.04 or 24.04 LTS
- Internet connection
- `sudo` privileges

## Quickstart

```bash
git clone https://github.com/your-username/ubuntu-terminal-setup.git
cd ubuntu-terminal-setup
./install.sh
```

## Usage

### Install

Install everything (default):
```bash
./install.sh
```

Install specific components:
```bash
./install.sh --only zsh
./install.sh --only vscode
./install.sh --only nvim
./install.sh --only docker
./install.sh --only git
```

Dry run (preview changes):
```bash
./install.sh --dry-run
```

Non-interactive mode:
```bash
./install.sh --yes
```

### Verify

Run the doctor script to verify the installation:
```bash
./doctor.sh
```

### Uninstall

Remove configurations (backups are restored if available):
```bash
./uninstall.sh
```

## Customization

- **Zsh**: Edit `config/zsh/.zshrc` before running install, or modify `~/.zshrc` after.
- **Neovim**: This repo installs a starter `init.lua` to `~/.config/nvim`. Modify `~/.config/nvim` directly after install.
- **VS Code**: Edit `config/vscode/settings.json` or `extensions.txt`.

## Troubleshooting

- **Docker Group**: If you can't run docker without sudo, you may need to log out and log back in for group changes to take effect.
- **VS Code Extensions**: If extensions fail to install, ensure `code` is in your PATH.

