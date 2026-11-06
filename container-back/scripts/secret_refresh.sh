if [[ ( "$refresh_db" == true && "$db_secret_created" == false ) || ( "$refresh_quarkus" == true && "$quarkus_secret_created" == false ) ]]; then

    echo "Deleting compose containers..."
    "$CONTAINER_ENGINE" compose "${compose_files[@]}" down

  if [[ "$CONTAINER_ENGINE" == "podman" ]]; then

    if [[ "$refresh_db" == true && "$db_secret_created" == false ]]; then
      echo "Deleting db secret..."
      if ! "$CONTAINER_ENGINE" secret rm "$secret_db_name"; then
          echo "ERROR: Unable to remove secret '$secret_db_name'."
          echo "A container outside the current Compose project may still be using this secret."
          echo "Please inspect and remove the dependent container before retrying."
          exit 1
      fi
      echo "Recreating db secret..."
      "$CONTAINER_ENGINE" secret create "$secret_db_name" "$db_secret_file"
      echo "Secret is ok for db."
    fi

    if [[ "$refresh_quarkus" == true && "$quarkus_secret_created" == false ]]; then
      echo "Deleting quarkus secret..."
      if ! "$CONTAINER_ENGINE" secret rm "$secret_quarkus_name"; then
          echo "ERROR: Unable to remove secret '$secret_quarkus_name'."
          echo "A container outside the current Compose project may still be using this secret."
          echo "Please inspect and remove the dependent container before retrying."
          exit 1
      fi
      echo "Recreating quarkus secret..."
      "$CONTAINER_ENGINE" secret create "$secret_quarkus_name" "$quarkus_secret_file"
      echo "Secret is ok for quarkus."
    fi

  fi

fi