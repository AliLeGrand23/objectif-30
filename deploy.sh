#!/bin/bash
# Déploie une nouvelle version d'Objectif 30.
# Usage : ./deploy.sh "ce que j'ai changé"
set -e
cd "$(dirname "$0")"

if [ -z "$1" ]; then echo "Il faut un message : ./deploy.sh \"ce que j'ai changé\""; exit 1; fi

V=$(date +%Y%m%d-%H%M)
# la version sert au diagnostic, elle est visible dans les réglages de l'app
sed -i '' "s/var APP_VERSION = \"[^\"]*\"/var APP_VERSION = \"$V\"/" index.html
grep -q "var APP_VERSION = \"$V\"" index.html || { echo "La version n'a pas été écrite dans index.html"; exit 1; }

node -e "
const fs=require('fs');
const s=fs.readFileSync('index.html','utf8');
new Function(s.split('<script>')[1].split('</'+'script>')[0]);
" || { echo "JavaScript invalide, rien n'est déployé"; exit 1; }

git add -A
git commit -q -m "$1"
git push -q origin main
echo "Déployé en version $V — ferme et rouvre l'app sur le téléphone pour la voir."
