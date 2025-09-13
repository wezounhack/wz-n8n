#!/bin/bash
docker pull wezoun/n8n:latest

# Arrête et supprime l'ancienne instance
docker stop n8n || true
docker rm n8n || true

# Démarre la nouvelle instance
docker run -d --name n8n -p 5678:5678 wezoun/n8n:latest

