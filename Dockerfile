FROM ubuntu:22.04

# Evoi interruzioni durante l'installazione dei pacchetti
ENV DEBIAN_FRONTEND=noninteractive

# Aggiungiamo l'architettura a 32 bit e installiamo Wine, Xvfb e Python
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    wine \
    wine32 \
    xvfb \
    python3 && \
    rm -rf /var/lib/apt/lists/*

# Impostiamo la cartella di lavoro principale nel container
WORKDIR /app

# Copiamo tutti i file (comprese le tue cartelle con dentro RakSAMP) nella directory di lavoro
COPY . /app

# Script di avvio robusto:
# 1. Avvia il server HTTP Python in background per mantenere la porta aperta per Render.
# 2. Aspetta 5 secondi per sicurezza.
# 3. Entra in ogni cartella presente, avvia RakSAMP con Wine tramite il display virtuale Xvfb in background.
# 4. 'wait' finale per mantenere il container costantemente attivo e vivo.
CMD /bin/bash -c "python3 -m http.server ${PORT:-10000} & \
    sleep 5 && \
    for d in */; do \
        if [ -d \"\$d\" ]; then \
            echo \"Avvio RakSAMP nella cartella: \$d\" && \
            cd \"\$d\" && \
            xvfb-run wine \"RakSAMP Lite.exe\" & \
            cd ..; \
        fi; \
    done && \
    wait"
