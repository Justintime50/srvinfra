# srvinfra

`srvinfra` is a tool to deploy, update, and maintain services and websites on a server hosted by Docker.

[![Build](https://github.com/Justintime50/srvinfra/workflows/build/badge.svg)](https://github.com/Justintime50/srvinfra/actions)
[![Version](https://img.shields.io/github/v/tag/justintime50/srvinfra)](https://github.com/justintime50/srvinfra/releases)
[![Licence](https://img.shields.io/github/license/justintime50/srvinfra)](LICENSE)

I store all my services and websites in the same place and have similar commands to update and deploy them but found myself needing to constantly navigate all over the filesystem to run Docker commands. With `srvinfra`, I can deploy and manage my services and websites with ease.

**NOTE:** This project is currently tailored towards my unique setup, longterm I'd love to allow this tool to be configurable to anyone's setup.

## Install

```bash
# Setup the tap
brew tap justintime50/formulas

# Install srvinfra
brew install srvinfra
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
srvinfra export_database DATABASE_CONTAINER_NAME ROOT_PASSWORD PATH_TO_SQL_FILE

# Export a compressed SQL databse from a Docker container and encrypt the backup (recommended)
# Default PATH_TO_SQL_FILE: './database.sql'
# Note: May need to quote `ROOT_PASSWORD`
srvinfra export_database_secure DATABASE_CONTAINER_NAME ROOT_PASSWORD PATH_TO_SQL_FILE

# Import a SQL database to a Docker container
# Note: May need to quote `ROOT_PASSWORD`
srvinfra import_database DATABASE_CONTAINER_NAME ROOT_PASSWORD PATH_TO_SQL_FILE

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
