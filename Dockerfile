FROM arm64v8/ubuntu:22.04

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Variables d'environnement pour Box64
ENV BOX64_WINE=1
ENV BOX64_DYNAREC_STRONGMEM=1
ENV BOX64_DYNAREC_BIGBLOCK=2
ENV BOX64_NOBANNER=1

# Installer les dépendances de base
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    cmake \
    python3 \
    xvfb \
    cabextract \
    unzip \
    libc6 \
    libgcc-s1 \
    && rm -rf /var/lib/apt/lists/*

# Compiler et installer Box64
RUN git clone https://github.com/ptitSeb/box64 /tmp/box64 && \
    cd /tmp/box64 && \
    mkdir build && cd build && \
    cmake .. -DARM_DYNAREC=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/box64

# Télécharger Wine x86_64 depuis le pool WineHQ
RUN mkdir -p /tmp/wine-install && cd /tmp/wine-install && \
    # Télécharger Wine devel amd64 (version récente disponible)
    wget https://dl.winehq.org/wine-builds/ubuntu/pool/main/wine-devel-amd64_4.0~rc2~artful_amd64.deb && \
    # Extraire le paquet
    dpkg-deb -x wine-devel-amd64_4.0~rc2~artful_amd64.deb /opt/wine-x86_64/ && \
    # Nettoyer
    cd / && rm -rf /tmp/wine-install

# Télécharger et installer SteamCMD x86_64
RUN mkdir -p /opt/steamcmd && \
    cd /opt/steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

# Créer les wrappers selon la doc Box64 (chemins Ubuntu Wine)
RUN echo '#!/bin/bash\nbox64 /opt/wine-x86_64/opt/wine-devel/bin/wine64 "$@"' > /usr/local/bin/wine64 && \
    chmod +x /usr/local/bin/wine64 && \
    echo '#!/bin/bash\nbox64 /opt/wine-x86_64/opt/wine-devel/bin/wine "$@"' > /usr/local/bin/wine && \
    chmod +x /usr/local/bin/wine && \
    echo '#!/bin/bash\nbox64 /opt/wine-x86_64/opt/wine-devel/bin/winecfg "$@"' > /usr/local/bin/winecfg && \
    chmod +x /usr/local/bin/winecfg && \
    echo '#!/bin/bash\nbox64 /opt/steamcmd/steamcmd.sh "$@"' > /usr/local/bin/steamcmd && \
    chmod +x /usr/local/bin/steamcmd

# Créer le répertoire serveur
RUN mkdir -p /server

# Copier le script d'entrée
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Exposer les ports
EXPOSE 7777/udp 27015/udp

# Point d'entrée
ENTRYPOINT ["/entrypoint.sh"]