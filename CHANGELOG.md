# CHANGELOG

## v0.6.3 (2022-01-07)

* Fixes the invocation of the `quiet-pull` flag on `update` actions

## v0.6.2 (2021-12-14)

* Uses the `quiet-pull` flag to suppress verbose (unnecessary) output during deployments

## v0.6.1 (2021-12-14)

* Updates path to projects

## v0.6.0 (2021-12-04)

* Docker compose commands changed from old `docker-compose` to new `docker compose` invocation

## v0.5.0 (2021-11-12)

* Added a parameter when importing/exporing databases to specify the database name instead of inferring it based on the image name (closes #1)

## v0.4.0 (2021-11-07)

* Adds new `decrypt_database_backup` command
* Adds new `export_database_secure` command
* Adds new `help` command to list all available commands

## v0.3.2-4 (2021-11-03)

* Fixes a bug that didn't properly pass the database name to the import/export function after the changes in `v0.3.1`

## v0.3.1 (2021-11-03)

* Adds default filename to sql export of `db.sql` in the current directory
* No longer assumes `-db` suffix on database container names (was not compatible with clustered containers)
* Changes directories when running the deploy commands instead of referencing `docker-compose` files from another directory (fixes an issue where relative paths inside of `docker-compose` files could not be found due to how we were referencing them)
* Removes a bunch of additional unnecessary `cd` commands

## v0.3.0 (2021-10-14)

* Adds `import_database` and `export_database` commands for easy data migration to and from Docker containers

## v0.2.0 (2021-10-12)

* Adds a new `status` command to retrieve the status of a Docker container by name
* Always rebuilds Docker images via `--build`

## v0.1.2 (2021-10-10)

* Fixes a bug where the reference to deploy a website was incorrect

## v0.1.1 (2021-10-10)

* Fixes a bug where parameters were offset by 1 (this was due to the command to run being the 1st parameter which offset everything by 1)

## v0.1.0 (2021-10-10)

* Initial release allowing one to update or deploy a website or service and update or deploy all of them
