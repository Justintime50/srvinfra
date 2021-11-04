#!/bin/bash

# Srvinfra is a tool to deploy and update services and websites on a server hosted by Docker

SERVICES_DIR="$HOME/git/personal/harvey/projects/justintime50/server-infra/src"
WEBSITE_DIR="$HOME/git/personal/harvey/projects"

# Deploy a service or website depending on context
deploy() {
    if [[ "$1" = "service" ]] ; then
        cd "$SERVICES_DIR"/"$2" || exit 1
        docker-compose -f docker-compose.yml up -d --build
    elif [[ "$1" = "website" ]] ; then
        cd "$WEBSITE_DIR"/"$2" || exit 1
        docker-compose -f docker-compose.yml -f docker-compose-prod.yml up -d --build
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
    for DIR in */ ; do
        echo "Deploying $DIR..."
        docker-compose -f "$DIR"/docker-compose.yml up -d --build
    done

    # Deploy websites
    cd "$WEBSITE_DIR" || exit 1
    for TOP_DIR in */ ; do
        cd "$TOP_DIR" || exit 1
        for DIR in */ ; do
            echo "Deploying $DIR..."
            docker-compose -f "$DIR"/docker-compose.yml -f "$DIR"/docker-compose-prod.yml up -d --build
        done
        cd .. || exit 1
    done
}

export_database() {
    # TODO: Don't send password on the CLI
    local sql_filename
    sql_filename=${3:-"db.sql"}

    local database_name
    database_name="$(echo "$1" | cut -d- -f1)"

    docker exec -i "$1" mysqldump -uroot -p"'$2'" "$database_name" > "$sql_filename"
}

import_database() {
    # TODO: Don't send password on the CLI
    local database_name
    database_name="$(echo "$1" | cut -d- -f1)"

    docker exec -i "$1" mysql -uroot -p"'$2'" "$database_name" < "$3"
}

# Get the status of a Docker container by name
status() {
    docker ps --filter name="$1"
}

# Update a single service, assumes the Docker tag has been updated or is not pinned
update() {
    echo "Updating $1..."
    cd "$SERVICES_DIR"/"$1" || exit 1
    docker-compose pull && docker-compose up -d --build || exit 1
    echo "$1 updated!"
}

# Updates all services, assumes the Docker tags have been updated or are not pinned
update_all() {
    echo "Updating all services..."
    cd "$SERVICES_DIR" || exit 1
    for DIR in */ ; do
        printf '%s\n' "$DIR"
        cd "$DIR" && docker-compose pull && docker-compose up -d --build
        echo "$DIR updating..."
        cd .. || exit 1
    done
}

command_router() {
    # Check if the command passed is valid or not. 
    # Run if it is a valid command, warn and exit if it is not.
    if type "$1" > /dev/null
    then
        "$@"
    else
        printf "%s\n" "\"$1\" is not a srvinfra command, please try again." >&2
        exit 1
    fi
}

command_router "$@"
