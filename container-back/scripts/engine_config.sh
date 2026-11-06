if [[ "$1" == "-d" || "$1" == "--docker" ]]; then
    CONTAINER_ENGINE="docker"
elif [[ "$1" != "-p" && "$1" != "--podman" && -n "$1" ]]; then
    echo "Error: argument not recognized. Exiting..."
    exit 1
fi

db_pw_checksum="$SCRIPT_DIR/container-back/.secrets/.checksum/$CONTAINER_ENGINE/db_pw_checksum.txt"
quarkus_pw_checksum="$SCRIPT_DIR/container-back/.secrets/.checksum/$CONTAINER_ENGINE/quarkus_pw_checksum.txt"

compose_files=(-f "$SCRIPT_DIR/compose.yaml" -f "$SCRIPT_DIR/compose.$CONTAINER_ENGINE.yaml")

# ==========================================
# ENVIRONMENT VERIFICATION
# ==========================================

command_available=$(command -v "$CONTAINER_ENGINE")

if [[ -z "$command_available" ]]; then
    echo "Error: $CONTAINER_ENGINE is not available. Exiting..."
    exit 1
fi

if ! "$CONTAINER_ENGINE" info > /dev/null; then
  echo "Unable to communicate with $CONTAINER_ENGINE. exiting..."
  exit 1
fi
