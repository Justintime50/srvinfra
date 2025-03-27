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

# Decrypt a database file so it can be inspected
# Parameters:
# 1. sql file path
# 2. sql file secret (for decryption)
decrypt_database_backup() {
    local output_sql_name
    output_sql_name="$(echo "$1" | cut -d. -f1)"

    openssl enc -aes-256-cbc -md sha512 -pbkdf2 -d -in "$1" -k "$2" | gzip -c -d >"$output_sql_name".sql
}

# Export a database from a container to a file (it will be in plain text)
# Parameters:
# 1. database container name
# 2. root password
# 3. database name
# 4. (optional) output sql file path
export_database() {
    local sql_filename
    sql_filename=${4:-"database.sql"}

    docker exec -i "$1" "$SRVINFRA_DATABASE_BACKUP_EXECUTABLE" -uroot -p"$2" "$3" >"$sql_filename" || {
        echo "Could not export database!"
        exit 1
    }

    # Check if we generate a proper export
    if [[ $(file "$sql_filename") != *ASCII\ text || ! -s "$sql_filename" ]]; then
        echo "The exported file is not valid SQL!"
        exit 1
    fi
}

# Export a database from a container to a file (it will be encrypted)
# Parameters:
# 1. database container name
# 2. root password
# 3. database name
# 4. (optional) output sql file path
export_database_secure() {
    local sql_filename
    sql_filename=${4:-"database.enc.gz"}

    docker exec -i "$1" "$SRVINFRA_DATABASE_BACKUP_EXECUTABLE" -uroot -p"$2" "$3" | gzip -c | openssl enc -aes-256-cbc -md sha512 -pbkdf2 -k "$2" >"$sql_filename" || {
        echo "Could not export database!"
        exit 1
    }

    # Check if we generate a proper export
    if [[ $(file "$sql_filename") != *"openssl enc'd data with salted password" || ! -s "$sql_filename" ]]; then
        echo "The exported file is not a valid encrypted file!"
        exit 1
    fi
}

# Import a plain-text database from a file to a database container
# Parameters:
# 1. database container name
# 2. root password
# 3. database name
# 4. sql file path
import_database() {
    docker exec -i "$1" "$SRVINFRA_DATABASE_EXECUTABLE" -uroot -p"$2" "$3" <"$4"
}

# Import an encrypted database from a file to a database container
# Parameters:
# 1. database container name
# 2. root password (assumed to be the same as the encrypted database secret)
# 3. database name
# 4. sql file path
import_encrypted_database() {
    local decrypted_sql_file_path
    decrypted_sql_file_path="$(echo "$4" | cut -d. -f1)".sql

    decrypt_database_backup "$4" "$2"

    import_database "$1" "$2" "$3" "$decrypted_sql_file_path"

    rm "$decrypted_sql_file_path" || exit 1
}

### Services

# Deploy a service using docker-compose
# Parameters:
# 1. service directory path (eg: justintime50/justinpaulhammond)
deploy() {
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

# Get the status of a Docker container by name
status() {
    docker ps --filter name="$1"
}

# Enter a Docker container's shell by closest match name (eg: partial name)
# Parameters:
# 1. container name
enter() {
    local container_id
    container_id=$(docker ps --filter "name=$1" --format "{{.ID}}" | head -n 1)
    docker exec -it "$container_id" sh
}

### Utilities

# Check if the command passed is valid or not.
# Run if it is a valid command, warn and exit if it is not.
command_router() {
    if type "$1" >/dev/null; then
        "$@"
    else
        printf "%s\n" "\"$1\" is not a srvinfra command, please try again." >&2
        exit 1
    fi
}

# Display help information about the tool
help() {
    echo "The following commands are available via 'srvinfra':"
    declare -F | awk '{print $NF}' | sort | grep -E -v "^_"
}

command_router "$@"
