#!/bin/bash

# Srvinfra is a tool to deploy and update services and websites on a server hosted by Docker

SERVICES_DIR="$HOME/git/personal/harvey/projects/justintime50/server-infra/src"
WEBSITE_DIR="$HOME/git/personal/harvey/projects"

deploy() {
    # Deploy a service or website depending on context
    if [[ "$2" = "service" ]] ; then
        docker-compose -f "$SERVICES_DIR"/"$3"/docker-compose.yml up -d
    elif [[ "$2" = "website" ]] ; then
        docker-compose -f "$WEBSITE_DIR"/"$3"/docker-compose.yml -f docker-compose-prod.yml up -d
    else
        echo "$2 isn't a valid action, try again."
    fi
}

deploy_all() {
    # Deploy all is perfect for a cold-start server deployment
    echo "You are about to deploy all production services and websites, before proceeding, ensure that Traefik is up and running. Press any button to continue."
    read -r
    echo "Deploying all services and websites..."

    # Deploy services
    cd "$SERVICES_DIR" || exit 1
    for DIR in */ ; do
        echo "Deploying $DIR..."
        docker-compose -f "$DIR"/docker-compose.yml up -d
    done
    cd || exit 1

    # Deploy websites
    cd "$WEBSITE_DIR" || exit 1
    for TOP_DIR in */ ; do
        cd "$TOP_DIR" || exit 1
        for DIR in */ ; do
            echo "Deploying $DIR..."
            docker-compose -f "$DIR"/docker-compose.yml -f "$DIR"/docker-compose-prod.yml up -d
        done
        cd .. || exit 1
    done
    cd || exit 1
}

update() {
    # Update a single service, assumes the Docker tag has been updated or is not pinned
    echo "Updating $2..."
    cd "$SERVICES_DIR"/"$2" || exit 1
    docker-compose pull && docker-compose up -d || exit 1
    cd || exit 1
    echo "$2 updated!"
}

update_all() {
    # Updates all services, assumes the Docker tags have been updated or are not pinned
    echo "Updating all services..."
    cd "$SERVICES_DIR" || exit 1
    for DIR in */ ; do
        printf '%s\n' "$DIR"
        cd "$DIR" && docker-compose pull && docker-compose up -d
        echo "$DIR updating..."
        cd .. || exit 1
    done
    cd || exit 1
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
