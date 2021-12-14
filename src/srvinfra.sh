#!/bin/bash

# Srvinfra is a tool to deploy and update services and websites on a server hosted by Docker

SERVICES_DIR="$HOME/harvey/projects/justintime50/server-infra/src"
WEBSITE_DIR="$HOME/harvey/projects"

### Databases

decrypt_database_backup() {
    # Parameters
    # 1. sql filename
    # 2. sql filename secret (for decryption)
    local output_sql_name
    output_sql_name="$(echo "$1" | cut -d. -f1)"

    openssl enc -aes-256-cbc -d -in "$1" -k "$2" | gzip -d >"$output_sql_name".sql
}

export_database() {
    # Parameters
    # 1. container name
    # 2. root password
    # 3. database name
    # 4. (optional) output sql filename
    local sql_filename
    sql_filename=${4:-"database.sql"}

    # TODO: Don't send password on the CLI
    docker exec -i "$1" mysqldump -uroot -p"$2" "$3" >"$sql_filename"
}

export_database_secure() {
    # Parameters
    # 1. container name
    # 2. root password
    # 3. database name
    # 4. (optional) output sql filename
    local sql_filename
    sql_filename=${4:-"database.enc.gz"}

    # TODO: Don't send password on the CLI
    docker exec -i "$1" mysqldump -uroot -p"$2" "$3" | gzip | openssl enc -aes-256-cbc -k "$2" >"$sql_filename"
}

import_database() {
    # Parameters
    # 1. container name
    # 2. root password
    # 3. database name
    # 4. output sql filename

    # TODO: Don't send password on the CLI
    docker exec -i "$1" mysql -uroot -p"$2" "$3" <"$4"
}

### Services

# Deploy a service or website depending on context
deploy() {
    # Parameters
    # 1. enum: service | website
    # 2. service/website directory path (eg: justintime50/justinpaulhammond)
    if [[ "$1" = "service" ]]; then
        cd "$SERVICES_DIR"/"$2" || exit 1
        docker compose -f docker-compose.yml up -d --build
    elif [[ "$1" = "website" ]]; then
        cd "$WEBSITE_DIR"/"$2" || exit 1
        docker compose -f docker-compose.yml -f docker-compose-prod.yml up -d --build --quiet-pull
    else
        echo "$1 isn't a valid action, try again."
    fi
}

# Deploy all is perfect for a cold-start server deployment
deploy_all() {
    echo "You are about to deploy all production services and websites, before proceeding, ensure that Traefik is up and running. Press any button to continue."
    read -r
    echo "Deploying all services and websites..."

    # Deploy services
    cd "$SERVICES_DIR" || exit 1
    for DIR in */; do
        echo "Deploying $DIR..."
        docker compose -f "$DIR"/docker-compose.yml up -d --build --quiet-pull
    done

    # Deploy websites
    cd "$WEBSITE_DIR" || exit 1
    for TOP_DIR in */; do
        cd "$TOP_DIR" || exit 1
        for DIR in */; do
            echo "Deploying $DIR..."
            docker compose -f "$DIR"/docker-compose.yml -f "$DIR"/docker-compose-prod.yml up -d --build --quiet-pull
        done
        cd .. || exit 1
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
    cd "$SERVICES_DIR"/"$1" || exit 1
    docker compose pull && docker-compose up -d --build --quiet || exit 1
    echo "$1 updated!"
}

# Updates all services, assumes the Docker tags have been updated or are not pinned
update_all() {
    echo "Updating all services..."
    cd "$SERVICES_DIR" || exit 1
    for DIR in */; do
        printf '%s\n' "$DIR"
        cd "$DIR" && docker compose pull && docker-compose up -d --build --quiet
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
