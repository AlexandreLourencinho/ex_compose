#!/usr/bin/env bash
#first line precise which interpreter to use
set -e #stop if errors

# ==========================================
# INITIALIZATION
# ==========================================

echo "secrets initialization..."
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
db_secret_file="$SCRIPT_DIR/container-back/.secrets/db_pw.txt"
quarkus_secret_file="$SCRIPT_DIR/container-back/.secrets/db.properties"
secret_db_name="db_password"
secret_quarkus_name="db_pw_prop"
db_secret_created=false
refresh_db=false
quarkus_secret_created=false
refresh_quarkus=false
CONTAINER_ENGINE="podman"

# ==========================================
# ENGINE SELECTION
# ==========================================

. "$SCRIPT_DIR/container-back/scripts/engine_config.sh"

# ==========================================
# SECRET FILES VERIFICATION
# ==========================================

echo "secrets verification..."

if [[ -f "$db_secret_file" ]]; then
    echo "Db secret file exist"
else
    echo "DB secret file is missing"
    exit 1
fi

if [[ -f "$quarkus_secret_file" ]]; then
    echo "Quarkus secret file exist"
else
    echo "Quarkus file is missing"
    exit 1
fi

if [[ ! -f "$db_pw_checksum" ]]; then
  touch "$db_pw_checksum"
fi

if [[ ! -f "$quarkus_pw_checksum" ]]; then
  touch "$quarkus_pw_checksum"
fi

if [[ "$CONTAINER_ENGINE" == "podman" ]]; then

  podman_secret_db=$("$CONTAINER_ENGINE" secret ls --filter name="^${secret_db_name}$" --format '{{.Name}}')
  podman_secret_quarkus=$("$CONTAINER_ENGINE" secret ls --filter name="^${secret_quarkus_name}$" --format '{{.Name}}')

  # ==========================================
  # PODMAN SECRET INITIALIZATION
  # ==========================================

  . "$SCRIPT_DIR/container-back/scripts/podman_secrets.sh"

fi

# ==========================================
# CHECKSUM VERIFICATION
# ==========================================

echo "Checking the quarkus pw checksum."
quarkus_pw_checksum_value=$(sha256sum "$quarkus_secret_file" | cut -d ' ' -f 1)
if [[ "$quarkus_pw_checksum_value" != "$(cat "$quarkus_pw_checksum")" ]]; then
    echo "Quarkus secret checksum does not match."
    refresh_quarkus=true
else
    echo "Quarkus checksum matches, nothing to do."
fi

echo "Checking the db pw checksum."
db_pw_checksum_value=$(sha256sum "$db_secret_file" | cut -d ' ' -f 1)
if [[ "$db_pw_checksum_value" != "$(cat "$db_pw_checksum")" ]]; then
    echo "db secret checksum does not match."
    refresh_db=true
else
    echo "db checksum matches, nothing to do."
fi

# ==========================================
# SECRET REFRESH
# ==========================================

. "$SCRIPT_DIR/container-back/scripts/secret_refresh.sh"

# ==========================================
# COMPOSE STARTUP
# ==========================================

"$CONTAINER_ENGINE" compose "${compose_files[@]}" up -d --build

if [[ "$refresh_quarkus" == true ]]; then
    echo "Refreshing quarkus checksum..."
    printf '%s\n' "$quarkus_pw_checksum_value" > "$quarkus_pw_checksum"
fi

if [[ "$refresh_db" == true ]]; then
    echo "Refreshing db checksum..."
    printf '%s\n' "$db_pw_checksum_value" > "$db_pw_checksum"
fi