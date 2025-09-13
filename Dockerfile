# Utilise l'image officielle de n8n comme base
FROM n8nio/n8n:latest

# Optionnel : Définir des variables d'environnement
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=password

# Optionnel : Exposer le port par défaut de n8n
EXPOSE 5678

# Vérifier que n8n est installé
RUN n8n --version

# Commande par défaut pour démarrer n8n
CMD ["n8n"]
