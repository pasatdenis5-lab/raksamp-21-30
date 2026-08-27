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
BOT="asuan[21]"\n\
\n\
if [ -d "/app/$BOT" ]; then\n\
    echo "[RENDER-BOT] Trovata cartella $BOT, avvio in corso..."\n\
    cd "/app/$BOT"\n\
    while true; do\n\
        wine "RakSAMP Lite.exe" 2>&1\n\
        echo "[RENDER-BOT] Bot disconnesso, riavvio tra 10 secondi..."\n\
        killall -9 wineserver wine-preloader wine 2>/dev/null\n\
        sleep 10;\n\
    done\n\
else\n\
    echo "ERRORE: La cartella $BOT non esiste in /app!"\n\
fi\n\
\n\
tail -f /dev/null' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

CMD ["/bin/bash", "/app/entrypoint.sh"]
