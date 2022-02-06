<div align="center">

# srvinfra

`srvinfra` is a tool to deploy, update, and maintain services and websites on a server hosted by Docker.

[![Build](https://github.com/Justintime50/srvinfra/workflows/build/badge.svg)](https://github.com/Justintime50/srvinfra/actions)
[![Version](https://img.shields.io/github/v/tag/justintime50/srvinfra)](https://github.com/justintime50/srvinfra/releases)
[![Licence](https://img.shields.io/github/license/justintime50/srvinfra)](LICENSE)

I store all my services and websites in the same place and have similar commands to update and deploy them but found myself needing to constantly navigate all over the filesystem to run Docker commands. With `srvinfra`, I can deploy and manage my services and websites with ease using a unified CLI syntax.

<img src="https://raw.githubusercontent.com/justintime50/assets/main/src/srvinfra/showcase.png" alt="Showcase">

</div>

## Install

```bash
# Setup the tap
brew tap justintime50/formulas

# Install srvinfra
brew install srvinfra
```

**NOTE:** `srvinfra` assumes `Docker Compose v2` is active and not `v1`.

Once you have `srvinfra` installed, you'll need to setup two environment variables:

```bash
echo 'export SRVINFRA_SERVICES_DIR=path/to/dir' >> ~/.zshrc
echo 'export SRVINFRA_WEBSITES_DIR=path/to/dir' >> ~/.zshrc
```

## Usage

```bash
# Deploy a service
srvinfra deploy service plex

# Deploy a website
srvinfra deploy website justintime50/justinpaulhammond

# Deploy all services and websites (great for server cold-start)
srvinfra deploy_all

# Decrypt a compressed SQL backup file
srvinfra decrypt_database_backup PATH_TO_SQL_FILE BACKUP_SECRET

# Export a SQL database from a Docker container
# Default PATH_TO_SQL_FILE: './database.sql'
# Note: May need to quote `ROOT_PASSWORD`
srvinfra export_database DATABASE_CONTAINER_NAME ROOT_PASSWORD DATABASE_NAME PATH_TO_SQL_FILE

# Export a compressed SQL databse from a Docker container and encrypt the backup (recommended)
# Default PATH_TO_SQL_FILE: './database.sql'
# Note: May need to quote `ROOT_PASSWORD`
srvinfra export_database_secure DATABASE_CONTAINER_NAME ROOT_PASSWORD DATABASE_NAME PATH_TO_SQL_FILE

# Import a SQL database to a Docker container
# Note: May need to quote `ROOT_PASSWORD`
srvinfra import_database DATABASE_CONTAINER_NAME ROOT_PASSWORD DATABASE_NAME PATH_TO_SQL_FILE

# Get the status of a Docker container by name
srvinfra status justinpaulhammond

# Update a service
srvinfra update plex

# Update all services
srvinfra update_all

# View all available commands
srvinfra help
```

## Development

```bash
# Lint the project
shellcheck src/srvinfra.sh
```
