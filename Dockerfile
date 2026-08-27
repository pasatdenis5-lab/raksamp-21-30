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
        (cd "/app/$bot" && while true; do wine "RakSAMP Lite.exe" 2>&1; sleep 30; done) &\n\
        sleep 2\n\
    fi\n\
done\n\
\n\
tail -f /dev/null' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

CMD ["/bin/bash", "/app/entrypoint.sh"]
