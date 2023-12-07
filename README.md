<div align="center">

# srvinfra

`srvinfra` is a tool to deploy, update, and maintain Docker projects hosted on a server.

[![Build](https://github.com/Justintime50/srvinfra/workflows/build/badge.svg)](https://github.com/Justintime50/srvinfra/actions)
[![Version](https://img.shields.io/github/v/tag/justintime50/srvinfra)](https://github.com/justintime50/srvinfra/releases)
[![Licence](https://img.shields.io/github/license/justintime50/srvinfra)](LICENSE)

<img src="https://raw.githubusercontent.com/justintime50/assets/main/src/srvinfra/showcase.png" alt="Showcase">

</div>

I store all my Docker services in the same place and have similar commands to update and deploy them but found myself needing to constantly navigate all over the filesystem to run Docker commands. With `srvinfra`, I can deploy and manage my services with ease from anywhere using a unified CLI syntax.

`srvinfra` will stash any local changes of a project, pull down new changes via `git`, then deploy the service via Docker. For services that have a production configuration, it will need to be titled `docker-compose-prod.yaml` and have a normal `docker-compose.yaml` file as well. Either `.yml` or `.yaml` extensions are supported. When a service does not have a production configuration, `srvinfra` will deploy using the base config.

## Install

```bash
# Setup the tap
brew tap justintime50/formulas

# Install srvinfra
brew install srvinfra
```

**NOTE:** `srvinfra` assumes `Docker Compose v2` is installed.

Once you have `srvinfra` installed, you'll need to setup an environment variable:

```bash
echo 'export SRVINFRA_SERVICES_DIR=path/to/dir' >> ~/.zshrc
```

You can change the database executable used from `mysql` to `mariadb` by setting it via the `SRVINFRA_DATABASE_EXECUTABLE` env var:

```bash
echo 'export SRVINFRA_DATABASE_EXECUTABLE=mariadb' >> ~/.zshrc
```

## Usage

> NOTE: You may need to quote `ROOT_PASSWORD` in the commands below.

```bash
# Deploy a service (relative from $SRVINFRA_SERVICES_DIR), subdirectories are possible
srvinfra deploy justintime50/justinpaulhammond
srvinfra deploy justintime50/server-infra/plex

# Deploy all services (great for server cold-start)
srvinfra deploy_all

# Decrypt a compressed SQL backup file
# The BACKUP_SECRET is assumed to be the same as the database ROOT_PASSWORD
srvinfra decrypt_database_backup PATH_TO_SQL_FILE BACKUP_SECRET

# Export a SQL database from a Docker container, unencrypted and uncompressed
# Default PATH_TO_SQL_FILE: './database.sql'
srvinfra export_database DATABASE_CONTAINER_NAME ROOT_PASSWORD DATABASE_NAME PATH_TO_SQL_FILE

# Export a compressed SQL database from a Docker container and encrypt the backup (recommended)
# Default PATH_TO_SQL_FILE: './database.enc.gz'
srvinfra export_database_secure DATABASE_CONTAINER_NAME ROOT_PASSWORD DATABASE_NAME PATH_TO_SQL_FILE

# Import a SQL database to a Docker container
srvinfra import_database DATABASE_CONTAINER_NAME ROOT_PASSWORD DATABASE_NAME PATH_TO_SQL_FILE

# Import an encrypted & compressed SQL database to a Docker container (command combines `decrypt_database_backup` and `import_database` commands)
# ROOT_PASSWORD is assumed to be the same as the database root password
srvinfra import_encrypted_database DATABASE_CONTAINER_NAME ROOT_PASSWORD DATABASE_NAME PATH_TO_SQL_FILE

# Get the status of a Docker container by name
srvinfra status justinpaulhammond

# Update a service
srvinfra update justintime50/server-infra/plex

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
