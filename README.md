# Dotfiles

Personal dotfiles and configuration management using a bare Git repository with chezmoi for secret templating.

## Features

- **Bare Git Repository**: Tracks dotfiles directly in `$HOME` without a working directory
- **Chezmoi Integration**: Template-based configuration with Bitwarden secret management
- **Homelab Secrets**: API keys and credentials managed via `rbw` (Bitwarden CLI)

## Fresh Installation

### Prerequisites

Install required tools:
```bash
# Ubuntu/Debian
sudo snap install chezmoi
sudo apt install git

# Install rbw (Bitwarden CLI)
cargo install rbw  # or use your package manager
```

### Clone and Setup

```bash
# Clone the bare repository
git clone --bare git@github.com:cmoates/dotfiles.git $HOME/.cfg

# Create alias for dotfiles management
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Configure the repository
config config --local status.showUntrackedFiles no

# Backup existing dotfiles (if any)
mkdir -p ~/.dotfiles-backup
config checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | xargs -I{} mv {} ~/.dotfiles-backup/{}

# Checkout dotfiles
config checkout

# Source the new bashrc to get the config alias
source ~/.bashrc
```

### Initialize Bitwarden and Chezmoi

```bash
# Login to Bitwarden
rbw login your-email@example.com
rbw unlock

# Apply chezmoi templates (pulls secrets from Bitwarden)
chezmoi apply

# Verify templates were applied
ls -la ~/plex-appliance/group_vars/
ls -la ~/homelab-gitops/
```

## Usage

### Managing Dotfiles

Use the `config` alias instead of `git`:

```bash
# Check status
config status

# Add a new dotfile
config add ~/.bashrc

# Commit changes
config commit -m "Update bashrc"

# Push to GitHub
config push origin main
```

### Managing Chezmoi Templates

Templates are stored in `~/.local/share/chezmoi/`:

```bash
# Edit a template
chezmoi edit ~/plex-appliance/group_vars/plex_servers.yml

# See what would change
chezmoi diff

# Apply templates
chezmoi apply

# Re-apply all templates
chezmoi apply --force
```

### Managing Secrets

All homelab secrets are in the `homelab` folder in Bitwarden:

```bash
# List secrets
rbw list --fields folder,name | grep '^homelab'

# Get a secret
rbw get tautulli-api-key

# Add a new secret (always use homelab folder)
echo 'secret-value' | rbw add secret-name --folder homelab

# Update a secret
rbw remove tautulli-api-key
echo 'new-value' | rbw add tautulli-api-key --folder homelab
```

After updating secrets, re-apply chezmoi templates:
```bash
chezmoi apply --force
```

## Directory Structure

```
~/.cfg/                                   # Bare git repository
~/.local/share/chezmoi/                   # Chezmoi source templates
  ├── plex-appliance/
  │   └── group_vars/
  │       └── plex_servers.yml.tmpl      # Bitwarden-backed template
  ├── homelab-gitops/
  │   └── dot_envrc.tmpl                 # Environment variables
  └── dot_bash_vikunja.tmpl              # Bash configuration
~/.config/chezmoi/
  └── chezmoistate.boltdb                # Chezmoi state database
```

## Secrets in Bitwarden

All homelab secrets are stored in the `homelab` folder:

| Secret Name | Purpose |
|-------------|---------|
| `tautulli-api-key` | Plex/Tautulli Prometheus metrics |
| `minio-prometheus-bearer-token` | MinIO Prometheus auth |
| `MinIO postgres-backups` | PostgreSQL backup credentials |
| `grafana.moat.es` | Grafana admin login |
| `minio.moat.es` | MinIO root credentials |
| `ha-token-vault92` | Home Assistant authentication |
| `*.moat.es` | Various homelab services |

## Troubleshooting

### Chezmoi templates not applying

```bash
# Force re-application
chezmoi apply --force

# Check what would change
chezmoi diff
```

### Bitwarden locked

```bash
# Unlock vault
rbw unlock

# Verify access
rbw get tautulli-api-key
```

### Conflicts on checkout

```bash
# Backup conflicting files
mkdir -p ~/.dotfiles-backup
config checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | xargs -I{} mv {} ~/.dotfiles-backup/{}

# Try checkout again
config checkout
```

## References

- [Bare Git Repository Method](https://www.atlassian.com/git/tutorials/dotfiles)
- [Chezmoi Documentation](https://www.chezmoi.io/)
- [rbw (Bitwarden CLI)](https://github.com/doy/rbw)
