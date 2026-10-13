#!/bin/bash

# Chargement de la configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_DIR/config/toolkit.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erreur : fichier de configuration introuvable."
    exit 1
fi

source "$CONFIG_FILE"

# Création du dossier des rapports
mkdir -p "$PROJECT_DIR/$REPORT_DIR"

# Nom du rapport
REPORT_FILE="$PROJECT_DIR/$REPORT_DIR/service-report.txt"

# Vérification des paramètres
if [ $# -eq 0 ]; then
    echo "Utilisation : $0 service1 service2 service3"
    exit 1
fi

# Initialisation du rapport
echo "===== RAPPORT DES SERVICES =====" > "$REPORT_FILE"
echo "Serveur : $SERVER_NAME" >> "$REPORT_FILE"
echo "Date : $(date)" >> "$REPORT_FILE"
echo "================================" >> "$REPORT_FILE"

# Fonction de vérification
check_service() {

    SERVICE="$1"

    echo ""
    echo "Vérification du service : $SERVICE"

    # Vérifier si le service existe
    if ! systemctl list-unit-files \
        --type=service --no-legend --no-pager \
        | awk '{print $1}' \
        | grep -Fxq "${SERVICE%.service}.service"; then

        MESSAGE="Service $SERVICE : INEXISTANT"

    # Vérifier si le service est actif
    elif systemctl is-active --quiet "$SERVICE"; then

        MESSAGE="Service $SERVICE : ACTIF"

    else

        MESSAGE="Service $SERVICE : INACTIF"

    fi

    # Affichage du résultat
    echo "$MESSAGE"

    # Enregistrement dans le rapport
    echo "$MESSAGE" >> "$REPORT_FILE"
}

# Vérification de tous les services fournis
for SERVICE in "$@"; do
    check_service "$SERVICE"
done

echo ""
echo "Rapport enregistré dans : $REPORT_FILE"
