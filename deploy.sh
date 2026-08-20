#!/bin/bash
# Déploie une nouvelle version d'Objectif 30.
# Usage : ./deploy.sh "ce que j'ai changé"
set -e
cd "$(dirname "$0")"

if [ -z "$1" ]; then echo "Il faut un message : ./deploy.sh \"ce que j'ai changé\""; exit 1; fi

V=$(date +%Y%m%d-%H%M)
# la version vit à deux endroits : dans la page et dans le fichier qu'elle interroge
sed -i '' "s/var APP_VERSION = \"[^\"]*\"/var APP_VERSION = \"$V\"/" index.html
printf '{"v":"%s"}\n' "$V" > version.json

# garde-fou : la page et le fichier doivent annoncer la même version
grep -q "var APP_VERSION = \"$V\"" index.html || { echo "La version n'a pas été écrite dans index.html"; exit 1; }

node -e "
const fs=require('fs');
const s=fs.readFileSync('index.html','utf8');
new Function(s.split('<script>')[1].split('</'+'script>')[0]);
" || { echo "JavaScript invalide, rien n'est déployé"; exit 1; }

git add -A
git commit -q -m "$1"
git push -q origin main
echo "Déployé en version $V — le bandeau de mise à jour apparaîtra sur le téléphone."
