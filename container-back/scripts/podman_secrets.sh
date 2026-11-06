  if [[ "$podman_secret_db" != "$secret_db_name" ]]; then
      echo "no podman db secret set up. setting up podman db secret"
      "$CONTAINER_ENGINE" secret create "$secret_db_name" "$db_secret_file"
      echo "db secret created"
      "$CONTAINER_ENGINE" secret ls --filter name="$secret_db_name"
      refresh_db=true
      db_secret_created=true
  else
      echo "db secret already set up."
  fi

  if [[ "$podman_secret_quarkus" != "$secret_quarkus_name" ]]; then
      echo "No podman quarkus secret set up. setting up podman quarkus secret"
      "$CONTAINER_ENGINE" secret create "$secret_quarkus_name" "$quarkus_secret_file"
      echo "Quarkus secret created"
      "$CONTAINER_ENGINE" secret ls --filter name="$secret_quarkus_name"
      refresh_quarkus=true
      quarkus_secret_created=true
  else
      echo "quarkus secret already set up."
  fi