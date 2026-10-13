
#!/bin/bash

# Vérification du nombre de paramètres
if [ "$#" -ne 1 ]; then
    echo "Erreur : vous devez préciser une cible."
    echo "Utilisation : $0 <adresse_IP_ou_domaine>"
    exit 2
fi

CIBLE="$1"

# Vérification du format de la cible
if [[ ! "$CIBLE" =~ ^[a-zA-Z0-9:.][a-zA-Z0-9:._-]*$ ]]; then
    echo "Erreur : format de cible invalide."
    exit 2
fi

# Vérification des commandes nécessaires
for cmd in ip ping tee; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        echo "Erreur : commande '$cmd' introuvable."
        exit 2
    fi
done

# Création du fichier de rapport
RAPPORT="rapport_reseau_$(date +%Y%m%d_%H%M%S).txt"

if ! touch "$RAPPORT"; then
    echo "Erreur : impossible de créer le rapport."
    exit 2
fi

# Fonction pour afficher et enregistrer les résultats
journaliser() {
    echo "$1" | tee -a "$RAPPORT"
}

journaliser "===== DIAGNOSTIC RESEAU ====="
journaliser "Date : $(date)"
journaliser "Machine : $(hostname)"
journaliser ""

# Informations sur les interfaces réseau
journaliser "===== INTERFACES RESEAU ====="
journaliser "$(ip -br addr)"
journaliser ""

# Adresses IPv4 et IPv6
journaliser "===== ADRESSES IPv4 ====="
journaliser "$(ip -4 -o addr show)"
journaliser ""

journaliser "===== ADRESSES IPv6 ====="
journaliser "$(ip -6 -o addr show)"
journaliser ""

# Passerelle par défaut
journaliser "===== PASSERELLE PAR DEFAUT ====="
PASSERELLE=$(ip route show default)
journaliser "${PASSERELLE:-Aucune passerelle IPv4 par défaut}"
journaliser ""

# Test de connectivité
journaliser "===== TEST DE CONNECTIVITE ====="
journaliser "Cible : $CIBLE"

RESULTAT=$(ping -c 4 -W 2 "$CIBLE" 2>&1)
CODE=$?

journaliser "$RESULTAT"

if [ "$CODE" -eq 0 ]; then
    journaliser "SUCCES : la cible répond au ping."
elif [ "$CODE" -eq 1 ]; then
    journaliser "ECHEC : aucune réponse de la cible."
    journaliser "La machine est inaccessible ou bloque les requêtes ICMP."
else
    journaliser "ERREUR : impossible d'effectuer le test."
    journaliser "Vérifiez le nom de la cible et la configuration réseau."
fi

journaliser ""
journaliser "Rapport enregistré dans : $RAPPORT"

exit "$CODE"
