#!/bin/bash
# Analyse d'un fichier journal : erreurs et avertissements
# Usage : ./analyse_log.sh fichier.log

# ===== CONFIGURATION =====
REPORT_DIR="$HOME/rapports-admin"
# =========================

LOG="$1"

# Vérification du paramètre
if [ -z "$LOG" ]; then
    echo "Usage : $0 fichier.log"
    exit 1
fi

# Vérification que le fichier existe et est lisible
if [ ! -f "$LOG" ]; then
    echo "Erreur : le fichier '$LOG' n'existe pas."
    exit 1
fi

if [ ! -r "$LOG" ]; then
    echo "Erreur : le fichier '$LOG' n'est pas lisible."
    exit 1
fi

mkdir -p "$REPORT_DIR"
FICHIER="$REPORT_DIR/analyse_$(basename "$LOG")_$(date +%Y%m%d_%H%M%S).txt"

# Comptages (-i : sans tenir compte des majuscules)
TOTAL=$(wc -l < "$LOG")
NB_ERREURS=$(grep -ciE "error|erreur|fatal|critical" "$LOG")
NB_WARN=$(grep -ciE "warn|avertissement" "$LOG")

{
    echo "===== ANALYSE DU JOURNAL ====="
    echo "Fichier : $LOG"
    echo "Date    : $(date '+%d/%m/%Y %H:%M:%S')"
    echo
    echo "===== RESUME ====="
    echo "Nombre total de lignes : $TOTAL"
    echo "Lignes d'erreur        : $NB_ERREURS"
    echo "Lignes d'avertissement : $NB_WARN"
    echo
    echo "===== ERREURS ====="
    grep -niE "error|erreur|fatal|critical" "$LOG"
    echo
    echo "===== AVERTISSEMENTS ====="
    grep -niE "warn|avertissement" "$LOG"
} | tee "$FICHIER"

echo
echo "Rapport enregistré : $FICHIER"