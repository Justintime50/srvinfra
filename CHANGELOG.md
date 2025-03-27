# CHANGELOG

## v2.0.0 (2025-03-26)

- Adds `srvinfra enter CONTAINER_NAME` allowing you to enter a Docker container with ease
- Removes functions:
  - `srvinfra deploy_all`
  - `srvinfra update`
  - `srvinfra update_all`

## v1.2.1 (2024-02-15)

- Fix a bug introduced in the last version that would exit with code 1 even with success due to bad syntax

## v1.2.0 (2024-02-08)

- Adds file checks on output database exports to ensure they are valid
- Adds error output when a database cannot be exported

## v1.1.0 (2023-09-30)

- Adds `SRVINFRA_DATABASE_EXECUTABLE` as an env var which can be set to `mariadb` to override the default `mysql` allowing users to change the database executable used with srvinfra
- Sets `set -e` flag to ensure srvinfra fails on any error where previously it could fail silently

## v1.0.0 (2023-08-25)

- Now uses `-md sha512 -pbkdf2` flags for openssl commands when encrypting and decrypting databases to fix deprecation warning
  - **NOTE:** Exported databases prior to v1.0.0 will not be able to be decrypted with this version due to the new flags, if older/newer database files need (d)encypring, you may need to change versions of this tool to match the one the original file was generated with
- Passes the `-c` command to gzip to supress the `unknown compression format` error

## v0.10.0 (2023-01-12)

- Consolidates `SRVINFRA_WEBSITES_DIR` and `SRVINFRA_SERVICES_DIR` into `SRVINFRA_SERVICES_DIR`
  - srvinfra will now determine if there are prod `docker-compose` files in the directory specified and use those when possible and do a normal `docker compose up` when not
  - When deploying a service, you will no longer need to specify `website` or `service` since srvinfra will determine which kind of `docker-compose` files are present and change the underlying command accordingly

## v0.9.1 (2022-11-28)

- Fixes a command that missed the force recreate flag

## v0.9.0 (2022-11-27)

- Force recreating containers even if config or images haven't changed

## v0.8.0 (2022-05-27)

- Attempts to start Traefik before other services on `deploy_all` command
- Adds an `import_encrypted_database` command that combines the `decrypt_database_backup` and `import_database` commands

## v0.7.0 (2022-02-06)

- Removes the hard-coded env vars of the website and service directories and adds instructions on how users can customize their own locations on installation

## v0.6.3 (2022-01-07)

- Fixes the invocation of the `quiet-pull` flag on `update` actions

## v0.6.2 (2021-12-14)

- Uses the `quiet-pull` flag to suppress verbose (unnecessary) output during deployments

## v0.6.1 (2021-12-14)

- Updates path to projects

## v0.6.0 (2021-12-04)

- Docker compose commands changed from old `docker-compose` to new `docker compose` invocation

## v0.5.0 (2021-11-12)

- Added a parameter when importing/exporing databases to specify the database name instead of inferring it based on the image name (closes #1)

## v0.4.0 (2021-11-07)

- Adds new `decrypt_database_backup` command
- Adds new `export_database_secure` command
- Adds new `help` command to list all available commands

## v0.3.2-4 (2021-11-03)

- Fixes a bug that didn't properly pass the database name to the import/export function after the changes in `v0.3.1`

## v0.3.1 (2021-11-03)

- Adds default filename to sql export of `db.sql` in the current directory
- No longer assumes `-db` suffix on database container names (was not compatible with clustered containers)
- Changes directories when running the deploy commands instead of referencing `docker-compose` files from another directory (fixes an issue where relative paths inside of `docker-compose` files could not be found due to how we were referencing them)
- Removes a bunch of additional unnecessary `cd` commands

## v0.3.0 (2021-10-14)

- Adds `import_database` and `export_database` commands for easy data migration to and from Docker containers

## v0.2.0 (2021-10-12)

- Adds a new `status` command to retrieve the status of a Docker container by name
- Always rebuilds Docker images via `--build`

## v0.1.2 (2021-10-10)

- Fixes a bug where the reference to deploy a website was incorrect

## v0.1.1 (2021-10-10)

- Fixes a bug where parameters were offset by 1 (this was due to the command to run being the 1st parameter which offset everything by 1)

## v0.1.0 (2021-10-10)

- Initial release allowing one to update or deploy a website or service and update or deploy all of them
