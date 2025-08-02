#!/bin/bash
set -e

# Variables d'environnement pour Box64 (redondant avec Dockerfile mais pour s'assurer)
export BOX64_WINE=1
export BOX64_DYNAREC_STRONGMEM=1
export BOX64_DYNAREC_BIGBLOCK=2
export BOX64_NOBANNER=1
export WINEPREFIX=/server/.wine

# Configuration des paramètres du serveur selon le projet original
SetUsePerfThreads="-useperfthreads "
if [[ $UsePerfThreads == "false" ]]; then
    SetUsePerfThreads=""
fi

SetNoAsyncLoadingThread="-NoAsyncLoadingThread "
if [[ $NoAsyncLoadingThread == "false" ]]; then
    SetNoAsyncLoadingThread=""
fi

# Variables par défaut (exactement comme le projet original)
MaxServerPlayers="${MaxServerPlayers:-6}"
Port="${Port:-7777}"
QueryPort="${QueryPort:-27015}"
ServerPassword="${ServerPassword:-password}"
SteamServerName="${SteamServerName:-LinuxServer}"
WorldSaveName="${WorldSaveName:-Cascade}"
AdditionalArgs="${AdditionalArgs:-}"

echo "=== Abiotic Factor ARM64 Server avec Box64 ==="
echo "Port: $Port"
echo "Query Port: $QueryPort"
echo "Max Players: $MaxServerPlayers"
echo "Server Name: $SteamServerName"
echo "World Save: $WorldSaveName"

# Initialiser Wine si nécessaire
if [ ! -d "$WINEPREFIX" ]; then
    echo "Initialisation de Wine..."
    wine64 wineboot --init
fi

# Vérifier les mises à jour ou effectuer l'installation initiale
# (copié exactement du script original avec steamcmd via notre wrapper)
if [ ! -d "/server/AbioticFactor/Binaries/Win64" ] || [[ $AutoUpdate == "true" ]]; then
    echo "Téléchargement/mise à jour du serveur Abiotic Factor..."
    steamcmd \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir /server \
        +login anonymous \
        +app_update 2857200 validate \
        +quit
    
    if [ $? -ne 0 ]; then
        echo "Erreur lors du téléchargement du serveur"
        exit 1
    fi
fi

# Vérifier que le serveur est installé
if [ ! -f "/server/AbioticFactor/Binaries/Win64/AbioticFactorServer-Win64-Shipping.exe" ]; then
    echo "Erreur: Le serveur Abiotic Factor n'est pas installé correctement"
    exit 1
fi

echo "Démarrage du serveur Abiotic Factor..."

# Se placer dans le répertoire du serveur (comme le script original)
pushd /server/AbioticFactor/Binaries/Win64 > /dev/null

# Démarrer le serveur (commande exacte du script original, mais avec wine64 via notre wrapper)
exec xvfb-run -a wine64 \
    AbioticFactorServer-Win64-Shipping.exe \
    $SetUsePerfThreads$SetNoAsyncLoadingThread-MaxServerPlayers=$MaxServerPlayers \
    -PORT=$Port \
    -QueryPort=$QueryPort \
    -SteamServerName="$SteamServerName" \
    -ServerPassword="$ServerPassword" \
    -WorldSaveName="$WorldSaveName" \
    $AdditionalArgs