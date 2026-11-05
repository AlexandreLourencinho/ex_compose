#!/usr/bin/env bash
#first line precise which interpreter to use
set -e #stop if errors
echo "secrets initialization..."
db_secret_file="container-back/.secrets/db_pw.txt"
quarkus_secret_file="container-back/.secrets/db.properties"
db_pw_checksum="container-back/.secrets/.checksum/db_pw_checksum.txt"
quarkus_pw_checksum="container-back/.secrets/.checksum/quarkus_pw_checksum.txt"
secret_db_name="db_password"
secret_quarkus_name="db_pw_prop"
refresh_db=false
refresh_quarkus=false

if ! [[ -e "$db_pw_checksum" ]]; then
  touch "$db_pw_checksum"
fi

if ! [[ -e "$quarkus_pw_checksum" ]]; then
  touch "$quarkus_pw_checksum"
fi

echo "secrets verification..."

if [[ -f "$db_secret_file" ]]; then
    echo "Db secret file exist"
else
    echo "Secret files is missing"
    exit 1
fi

if [[ -f "$quarkus_secret_file" ]]; then
    echo "Quarkus secret file exist"
else
    echo "Quarkus file is missing"
    exit 1
fi

podman_secret_db=$(podman secret ls --filter name="^${secret_db_name}$" --format '{{.Name}}')
if [[ "$podman_secret_db" != "$secret_db_name" ]]; then
    echo "no podman db secret set up. setting up podman db secret"
    podman secret create "$secret_db_name" "$db_secret_file"
    echo "db secret created"
    podman secret ls --filter name="$secret_db_name"
    sha256sum "$db_secret_file" | cut -d ' ' -f 1 > "$db_pw_checksum"
else
    echo "db secret already set up. Checking the checksum."
    db_pw_checksum_value=$(sha256sum "$db_secret_file" | cut -d ' ' -f 1)
    if [[ "$db_pw_checksum_value" != "$(cat "$db_pw_checksum")" ]]; then
        echo "db secret checksum does not match."
        refresh_db=true
    else
        echo "db checksum matches, nothing to do."
    fi
fi

podman_secret_quarkus=$(podman secret ls --filter name="^${secret_quarkus_name}$" --format '{{.Name}}')

if [[ "$podman_secret_quarkus" != "$secret_quarkus_name" ]]; then
    echo "No podman quarkus secret set up. setting up podman quarkus secret"
    podman secret create "$secret_quarkus_name" "$quarkus_secret_file"
    echo "Quarkus secret created"
    podman secret ls --filter name="$secret_quarkus_name"
    sha256sum "$quarkus_secret_file" | cut -d ' ' -f 1 > "$quarkus_pw_checksum"
else
    echo "quarkus secret already set up. Checking the checksum."
    quarkus_pw_checksum_value=$(sha256sum "$quarkus_secret_file" | cut -d ' ' -f 1)
    if [[ "$quarkus_pw_checksum_value" != "$(cat "$quarkus_pw_checksum")" ]]; then
        echo "Quarkus secret checksum does not match."
        refresh_quarkus=true
    else
        echo "Quarkus checksum matches, nothing to do."
    fi
fi

if [[ "$refresh_db" == true || "$refresh_quarkus" == true ]]; then
  echo "Deleting compose containers..."
  podman compose down

  if [[ "$refresh_db" == true ]]; then
    echo "Deleting db secret..."
    if ! podman secret rm "$secret_db_name"; then
        echo "ERROR: Unable to remove secret '$secret_db_name'."
        echo "A container outside the current Compose project may still be using this secret."
        echo "Please inspect and remove the dependent container before retrying."
        exit 1
    fi
    echo "Recreating db secret..."
    podman secret create "$secret_db_name" "$db_secret_file"
    echo "Refreshing checksum..."
    printf '%s\n' "$db_pw_checksum_value" > "$db_pw_checksum"
    echo "Secret is ok for db."
  fi

  if [[ "$refresh_quarkus" == true ]]; then
    echo "Deleting quarkus secret..."
    if ! podman secret rm "$secret_quarkus_name"; then
        echo "ERROR: Unable to remove secret '$secret_quarkus_name'."
        echo "A container outside the current Compose project may still be using this secret."
        echo "Please inspect and remove the dependent container before retrying."
        exit 1
    fi
    echo "Recreating quarkus secret..."
    podman secret create "$secret_quarkus_name" "$quarkus_secret_file"
    echo "Refreshing checksum..."
    printf '%s\n' "$quarkus_pw_checksum_value" > "$quarkus_pw_checksum"
    echo "Secret is ok for quarkus."
  fi

fi


