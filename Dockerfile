FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    WINEDEBUG=-all \
    WINEPREFIX=/root/.wine32 \
    WINEARCH=win32

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends wine wine32 xvfb python3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

RUN echo '#!/bin/bash\n\
Xvfb :99 -screen 0 800x600x8 &\n\
sleep 2\n\
python3 -m http.server ${PORT:-10000} &\n\
\n\
BOTS=("asuan17")\n\
\n\
for bot in "${BOTS[@]}"; do\n\
    if [ -d "/app/$bot" ]; then\n\
        echo "[RENDER-BOT] Avvio $bot..."\n\
        (cd "/app/$bot" && while true; do \n\
            wine "RakSAMP Lite.exe" 2>&1 | while read -r line; do\n\
                if echo "$line" | grep -qiE "full|banned|ip|reject|error|timeout"; then\n\
                    echo "[BOT-ALERT] $bot -> Stato critico rilevato: $line";\n\
                elif echo "$line" | grep -qiE "join|connected|spawn|spawned"; then\n\
                    echo "[BOT-STATUS] $bot -> Connesso con successo al server!";\n\
                fi;\n\
            done\n\
            echo "[RENDER-BOT] $bot disconnesso, pulizia e riavvio tra 10 secondi..."\n\
            killall -9 wineserver wine-preloader wine 2>/dev/null\n\
            sleep 10;\n\
        done) &\n\
        sleep 2\n\
    fi\n\
done\n\
\n\
tail -f /dev/null' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

CMD ["/bin/bash", "/app/entrypoint.sh"]
