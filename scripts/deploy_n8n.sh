#!/bin/bash

# Variables
IMAGE_NAME=$1

# Arrêter et supprimer le conteneur existant (s'il existe)
docker stop n8n || true
docker rm n8n || true

# Supprimer l'image existante (s'il existe)
docker rmi $IMAGE_NAME || true

# Télécharger et exécuter la nouvelle image
docker pull $IMAGE_NAME
docker run -d --name n8n -p 5678:5678 $IMAGE_NAME

# Vérifier que le conteneur est en cours d'exécution
docker ps --filter "name=n8n"
