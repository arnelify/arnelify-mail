#!/bin/bash
set -e
mkdir -p ./dist
mkdir -p ./src
DOCKER_PATH="$(dirname "$(readlink -f "$0")")/docker"
DOCKER_COMPOSE_CONTENT="$(cat "$DOCKER_PATH/base.part.yml")"
ROOT_PATH="$(dirname "$DOCKER_PATH")"
ROOT_NAME=$(basename "$ROOT_PATH")
if [[ ! -x docker ]]; then
  echo "It looks like Docker is not installed on system"
  echo "More information about the requirements can be found in 'readme.md'"
  exit 1
fi
DOCKER_VERSION=$(docker -v)
echo "[*] ${DOCKER_VERSION}"



# COMMAND: PROD / DEV
if [ "$1" == "prod" ] || [ "$1" == "dev" ]; then

  rm -f "$ROOT_PATH"/*.dockerfile
  rm -f "$ROOT_PATH"/*.yml

  for MODULE_PATH in "$DOCKER_PATH"/*; do

    if [ -d "$MODULE_PATH" ]; then
      MODULE_NAME=$(basename "$MODULE_PATH")

      # CREATE DOCKERFILE
      MODULE_DOCKER_FILENAME="$MODULE_PATH/$1.dockerfile"
      DOCKER_FILE="$MODULE_NAME.dockerfile"

      if [ -f "$MODULE_DOCKER_FILENAME" ]; then
        cp -f "$MODULE_DOCKER_FILENAME" "$ROOT_PATH/$DOCKER_FILE"
        echo "[*] Created: $ROOT_PATH/$DOCKER_FILE"
      fi

      # ADD YML
      MODULE_YML_FILE="$MODULE_PATH/$1.part.yml"
      if [ -f "$MODULE_YML_FILE" ]; then
        DOCKER_COMPOSE_CONTENT+=$'\n'"$(cat "$MODULE_YML_FILE")"
      fi
    fi
  done

  # CREATE YML
  YML_FILE="docker-compose.yml"
  YML_FILENAME="$ROOT_PATH/$YML_FILE"
  echo -ne "$DOCKER_COMPOSE_CONTENT" > "$YML_FILENAME"
  echo "[*] Created: $ROOT_PATH/$YML_FILE"

  # BUILD
  docker compose up -d
  #if [ "$1" == "dev" ]; then 
  #  CONTAINER_ID=$(docker ps -f "ancestor=$ROOT_NAME-nodejs" -q)
  #  docker exec -it "$CONTAINER_ID" yarn start
  #fi

  echo "Done."
  exit 1
fi



# COMMAND: CLEAN
if [ "$1" == "clean" ]; then

  docker compose down -v

  for MODULE_PATH in "$DOCKER_PATH"/*; do
    if [ -d "$MODULE_PATH" ]; then
      MODULE_NAME=$(basename "$MODULE_PATH")
      IMAGE_NAME="$ROOT_NAME-$MODULE_NAME"

      if docker image inspect "$IMAGE_NAME" &> /dev/null; then docker rmi "$IMAGE_NAME"; fi
    fi
  done

  echo "Done."
  exit 1
fi



# COMMAND: BACKUP
if [ "$1" == "backup" ] || [ "$1" == "protected-backup" ]; then
  mkdir -p ./backups
  rm -rf ./dist
  rm -rf ./linux64
  rm -rf ./src/node_modules
  
  if [ "$1" == "protected-backup" ]; then
    zip -er "$ROOT_PATH/backups/$ROOT_NAME-$(date +%Y-%m-%d)-protected.zip" "./"
  else
    zip -r "$ROOT_PATH/backups/$ROOT_NAME-$(date +%Y-%m-%d).zip" "./"
  fi

  mkdir -p ./dist
  echo "Done."
  exit 1
fi



# COMMAND IS MISSING
echo -e "You need to specify COMMAND like: \n$0 [prod|dev|backup|protected-backup|clean]\n"
exit 1