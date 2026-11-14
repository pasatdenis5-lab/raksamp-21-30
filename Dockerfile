FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    WINEDEBUG=-all \
    WINEPREFIX=/root/.wine32 \
    WINEARCH=win32

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends wine wine32 xvfb x11vnc novnc websockify fluxbox && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

RUN echo '#!/bin/bash\n\
Xvfb :99 -screen 0 1024x768x16 &\n\
sleep 2\n\
fluxbox &\n\
sleep 1\n\
x11vnc -display :99 -nopw -forever -shared -listen localhost -rfbport 5900 &\n\
sleep 2\n\
websockify --web=/usr/share/novnc/ 0.0.0.0:${PORT:-10000} localhost:5900 &\n\
\n\
BOTS=("asuan[1]" "asuan[2]" "asuan[3]" "asuan[4]" "asuan[5]" "asuan[6]" "asuan[8]" "asuan[9]" "asuan[10]" "asuan[21]")\n\
\n\
for bot in "${BOTS[@]}"; do\n\
    if [ -d "/app/$bot" ]; then\n\
        echo "[RENDER-BOT] Avvio $bot..."\n\
        (cd "/app/$bot" && while true; do \n\
            wine "RakSAMP Lite.exe" 2>&1\n\
            wineserver -k 2>/dev/null\n\
            sleep 10;\n\
        done) &\n\
        sleep 5\n\
    fi\n\
done\n\
\n\
tail -f /dev/null' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

CMD ["/bin/bash", "/app/entrypoint.sh"]
