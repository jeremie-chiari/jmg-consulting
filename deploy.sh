#!/bin/bash
set -e

# ============ CONFIG ============
APP_NAME="jmg-consulting"
VPS="isaoprod"
VPS_DIR="/data/$APP_NAME"
REPO_URL="git@github-judu:jeremie-chiari/$APP_NAME.git"
# ================================

echo "🚀 Déploiement de $APP_NAME"

# 1. Vérifications locales
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ STOP : Fichiers non commités !"
    git status --short
    exit 1
fi

LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse origin/main 2>/dev/null || echo "none")
if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    echo "📤 Push en cours..."
    git push origin main
fi

# 2. Déploiement VPS
echo "🖥️  Déploiement sur le VPS..."
ssh $VPS << DEPLOY
set -e
if [ ! -d "$VPS_DIR" ]; then
    git clone $REPO_URL $VPS_DIR
    cd $VPS_DIR
else
    cd $VPS_DIR
    git fetch origin
    git reset --hard origin/main
fi
docker network ls | grep -q app-network || docker network create app-network
docker compose up -d --build --force-recreate
sleep 3
if docker ps | grep -q "$APP_NAME"; then
    echo "✅ Container $APP_NAME tourne"
else
    echo "❌ Container $APP_NAME ne tourne pas !"
    docker logs $APP_NAME --tail 20
    exit 1
fi
DEPLOY

echo "✅ $APP_NAME déployé !"
echo "🔗 Pense à vérifier/ajouter l'entrée Caddy si premier deploy"
