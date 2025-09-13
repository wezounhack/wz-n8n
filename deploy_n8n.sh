#!/bin/bash
set -euo pipefail

IMAGE="${1:-wezoun/n8n:latest}"
CONTAINER_NAME="n8n"
DATA_DIR="/home/${USER}/.n8n"

mkdir -p "${DATA_DIR}"

echo "Déploiement de l'image ${IMAGE}..."

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "${CONTAINER_NAME}" || true)
  echo "${CURRENT_IMAGE}" > "/home/${USER}/.n8n_last_tag" || true
fi

docker pull "${IMAGE}"

docker stop "${CONTAINER_NAME}" || true
docker rm "${CONTAINER_NAME}" || true

docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  --env-file "${ENV_FILE}" \
  -v "${DATA_DIR}:/home/node/.n8n" \
  -p 5678:5678 \
  --health-cmd='curl -fsS http://localhost:5678/ || exit 1' \
  --health-interval=10s \
  --health-retries=12 \
  "${IMAGE}"

# Vérification santé et rollback si nécessaire
# (identiques à l’exemple précédent)
