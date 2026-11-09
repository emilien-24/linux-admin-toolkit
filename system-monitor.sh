#!/bin/bash

# ===== CONFIGURATION =====
REPORT_DIR="$HOME/rapports-admin"
# =========================

mkdir -p "$REPORT_DIR"
FICHIER="$REPORT_DIR/rapport_$(hostname)_$(date +%Y%m%d_%H%M%S).txt"

{
    echo "===== RAPPORT SERVEUR ====="
    echo "Serveur : $(hostname)"
    echo "Date    : $(date '+%d/%m/%Y %H:%M:%S')"
    echo
    echo "===== MEMOIRE ====="
    free -h
    echo
    echo "===== DISQUES ====="
    df -h -x tmpfs -x devtmpfs
    echo
    echo "===== CHARGE ====="
    uptime
} | tee "$FICHIER"

echo
echo "Rapport enregistré : $FICHIER"