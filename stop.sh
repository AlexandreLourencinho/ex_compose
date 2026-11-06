CONTAINER_ENGINE="podman"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/container-back/scripts/engine_config.sh"

"$CONTAINER_ENGINE" compose "${compose_files[@]}" down