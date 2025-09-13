#!/bin/bash
set -euo pipefail

IMAGE="${1:-votre-dockerhub-username/n8n:latest}"
CONTAINER_NAME="n8n"
DATA_DIR="/home/${USER}/.n8n"
ENV_FILE="/home/${USER}/n8n.env"
PREV_TAG_FILE="/home/${USER}/.n8n_last_tag"

mkdir -p "${DATA_DIR}"

echo "Déploiement de l'image ${IMAGE}..."

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "${CONTAINER_NAME}" || true)
  echo "${CURRENT_IMAGE}" > "${PREV_TAG_FILE}" || true
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

# Vérifier la santé
echo "Vérification santé..."
for i in {1..12}; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' "${CONTAINER_NAME}" || echo "none")
  echo "Tentative $i, état=$STATUS"
  if [ "$STATUS" = "healthy" ]; then
    echo "Container sain."
    exit 0
  fi
  sleep 10
done

# Rollback si non sain
echo "Échec, rollback..."
if [ -f "${PREV_TAG_FILE}" ]; then
  PREV_IMAGE=$(cat "${PREV_TAG_FILE}")
  echo "Rollback vers ${PREV_IMAGE}"
  docker pull "${PREV_IMAGE}" || true
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
    "${PREV_IMAGE}"
  echo "Rollback exécuté."
  exit 1
fi

echo "Aucun rollback, container pas healthy."
exit 1
