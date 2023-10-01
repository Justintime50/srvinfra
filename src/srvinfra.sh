#!/bin/bash

# srvinfra is a tool to deploy and update services on a server hosted by Docker

set -e

### Databases

SRVINFRA_DATABASE_EXECUTABLE=${SRVINFRA_DATABASE_EXECUTABLE:-"mysql"}

if [[ "$SRVINFRA_DATABASE_EXECUTABLE" == "mariadb" ]]; then
    SRVINFRA_DATABASE_BACKUP_EXECUTABLE="mariadb-dump"
else
    SRVINFRA_DATABASE_BACKUP_EXECUTABLE="mysqldump"
fi

decrypt_database_backup() {
    # Parameters
    # 1. sql file path
    # 2. sql file secret (for decryption)
    local output_sql_name
    output_sql_name="$(echo "$1" | cut -d. -f1)"

    openssl enc -aes-256-cbc -md sha512 -pbkdf2 -d -in "$1" -k "$2" | gzip -c -d >"$output_sql_name".sql
}

export_database() {
    # Parameters
    # 1. database container name
    # 2. root password
    # 3. database name
    # 4. (optional) output sql file path
    local sql_filename
    sql_filename=${4:-"database.sql"}

    docker exec -i "$1" "$SRVINFRA_DATABASE_BACKUP_EXECUTABLE" -uroot -p"$2" "$3" >"$sql_filename"
}

export_database_secure() {
    # Parameters
    # 1. database container name
    # 2. root password
    # 3. database name
    # 4. (optional) output sql file path
    local sql_filename
    sql_filename=${4:-"database.enc.gz"}

    docker exec -i "$1" "$SRVINFRA_DATABASE_BACKUP_EXECUTABLE" -uroot -p"$2" "$3" | gzip -c | openssl enc -aes-256-cbc -md sha512 -pbkdf2 -k "$2" >"$sql_filename"
}

import_database() {
    # Parameters
    # 1. database container name
    # 2. root password
    # 3. database name
    # 4. sql file path

    docker exec -i "$1" "$SRVINFRA_DATABASE_EXECUTABLE" -uroot -p"$2" "$3" <"$4"
}

import_encrypted_database() {
    # Parameters
    # 1. database container name
    # 2. root password (assumed to be the same as the encrypted database secret)
    # 3. database name
    # 4. sql file path

    local decrypted_sql_file_path
    decrypted_sql_file_path="$(echo "$4" | cut -d. -f1)".sql

    decrypt_database_backup "$4" "$2"

    import_database "$1" "$2" "$3" "$decrypted_sql_file_path"

    rm "$decrypted_sql_file_path" || exit 1
}

### Services

# Deploy a service
deploy() {
    # Parameters
    # 1. service directory path (eg: justintime50/justinpaulhammond)
    cd "$SRVINFRA_SERVICES_DIR"/"$1" || exit 1
    git stash && git pull

    if [[ -f "docker-compose-prod.yml" ]]; then
        docker compose -f docker-compose.yml -f docker-compose-prod.yml up -d --build --force-recreate --quiet-pull
    elif [[ -f "docker-compose-prod.yaml" ]]; then
        docker compose -f docker-compose.yaml -f docker-compose-prod.yaml up -d --build --force-recreate --quiet-pull
    else
        docker compose -d --build --force-recreate --quiet-pull
    fi
}

# Deploy all is perfect for a cold-start server deployment
deploy_all() {
    echo "You are about to deploy all production services. Press any button to continue."
    read -r
    echo "Deploying all services..."

    # Deploy Traefik before other services
    cd "$SRVINFRA_SERVICES_DIR/traefik" || exit 0 # don't fail if traefik doesn't exist
    docker compose up -d --build --force-recreate --quiet-pull
    cd || exit 1

    # Deploy services
    cd "$SRVINFRA_SERVICES_DIR" || exit 1
    for DIR in */; do
        echo "Deploying $DIR..."
        git stash && git pull

        if [[ -f "docker-compose-prod.yml" ]]; then
            docker compose -f docker-compose.yml -f docker-compose-prod.yml up -d --build --force-recreate --quiet-pull
        elif [[ -f "docker-compose-prod.yaml" ]]; then
            docker compose -f docker-compose.yaml -f docker-compose-prod.yaml up -d --build --force-recreate --quiet-pull
        else
            docker compose -d --build --force-recreate --quiet-pull
        fi
    done
}

# Get the status of a Docker container by name
status() {
    docker ps --filter name="$1"
}

# Update a single service, assumes the Docker tag has been updated or is not pinned
update() {
    # Parameters
    # 1. service name
    echo "Updating $1..."
    cd "$SRVINFRA_SERVICES_DIR"/"$1" || exit 1
    docker compose pull && docker compose up -d --build --force-recreate --quiet-pull || exit 1
    echo "$1 updated!"
}

# Updates all services, assumes the Docker tags have been updated or are not pinned
update_all() {
    echo "Updating all services..."
    cd "$SRVINFRA_SERVICES_DIR" || exit 1
    for DIR in */; do
        printf '%s\n' "$DIR"
        cd "$DIR" && docker compose pull && docker compose up -d --build --force-recreate --quiet-pull
        echo "$DIR updating..."
        cd .. || exit 1
    done
}

### Utilities

command_router() {
    # Check if the command passed is valid or not.
    # Run if it is a valid command, warn and exit if it is not.
    if type "$1" >/dev/null; then
        "$@"
    else
        printf "%s\n" "\"$1\" is not a srvinfra command, please try again." >&2
        exit 1
    fi
}

help() {
    echo "The following commands are available via 'srvinfra':"
    declare -F | awk '{print $NF}' | sort | grep -E -v "^_"
}

command_router "$@"
