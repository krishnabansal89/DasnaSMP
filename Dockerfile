# Minecraft SMP Server Dockerfile
FROM openjdk:21-jre-slim

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create minecraft user and directory
RUN useradd -m -u 1000 minecraft
WORKDIR /minecraft
RUN chown minecraft:minecraft /minecraft

# Switch to minecraft user
USER minecraft

# Environment variables
ENV MINECRAFT_VERSION=1.21.1
ENV SERVER_JAR=server.jar
ENV MEMORY_SIZE=2G
ENV JAVA_OPTS="-Xmx${MEMORY_SIZE} -Xms${MEMORY_SIZE}"

# Download Minecraft server jar
RUN wget -O ${SERVER_JAR} https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar

# Create server.properties with default SMP settings
RUN echo "# Minecraft server properties" > server.properties && \
    echo "enable-jmx-monitoring=false" >> server.properties && \
    echo "rcon.port=25575" >> server.properties && \
    echo "level-seed=" >> server.properties && \
    echo "gamemode=survival" >> server.properties && \
    echo "enable-command-block=false" >> server.properties && \
    echo "enable-query=false" >> server.properties && \
    echo "generator-settings={}" >> server.properties && \
    echo "enforce-secure-profile=true" >> server.properties && \
    echo "level-name=world" >> server.properties && \
    echo "motd=A Minecraft SMP Server" >> server.properties && \
    echo "query.port=25565" >> server.properties && \
    echo "pvp=true" >> server.properties && \
    echo "generate-structures=true" >> server.properties && \
    echo "max-chained-neighbor-updates=1000000" >> server.properties && \
    echo "difficulty=normal" >> server.properties && \
    echo "network-compression-threshold=256" >> server.properties && \
    echo "max-tick-time=60000" >> server.properties && \
    echo "require-resource-pack=false" >> server.properties && \
    echo "use-native-transport=true" >> server.properties && \
    echo "max-players=20" >> server.properties && \
    echo "online-mode=true" >> server.properties && \
    echo "enable-status=true" >> server.properties && \
    echo "allow-flight=false" >> server.properties && \
    echo "initial-disabled-packs=" >> server.properties && \
    echo "broadcast-rcon-to-ops=true" >> server.properties && \
    echo "view-distance=10" >> server.properties && \
    echo "server-ip=" >> server.properties && \
    echo "resource-pack-prompt=" >> server.properties && \
    echo "allow-nether=true" >> server.properties && \
    echo "server-port=25565" >> server.properties && \
    echo "enable-rcon=false" >> server.properties && \
    echo "sync-chunk-writes=true" >> server.properties && \
    echo "op-permission-level=4" >> server.properties && \
    echo "prevent-proxy-connections=false" >> server.properties && \
    echo "hide-online-players=false" >> server.properties && \
    echo "resource-pack=" >> server.properties && \
    echo "entity-broadcast-range-percentage=100" >> server.properties && \
    echo "simulation-distance=10" >> server.properties && \
    echo "rcon.password=" >> server.properties && \
    echo "player-idle-timeout=0" >> server.properties && \
    echo "force-gamemode=false" >> server.properties && \
    echo "rate-limit=0" >> server.properties && \
    echo "hardcore=false" >> server.properties && \
    echo "white-list=false" >> server.properties && \
    echo "broadcast-console-to-ops=true" >> server.properties && \
    echo "spawn-npcs=true" >> server.properties && \
    echo "spawn-animals=true" >> server.properties && \
    echo "function-permission-level=2" >> server.properties && \
    echo "initial-enabled-packs=vanilla" >> server.properties && \
    echo "level-type=minecraft\\:normal" >> server.properties && \
    echo "text-filtering-config=" >> server.properties && \
    echo "spawn-monsters=true" >> server.properties && \
    echo "enforce-whitelist=false" >> server.properties && \
    echo "spawn-protection=16" >> server.properties && \
    echo "resource-pack-sha1=" >> server.properties && \
    echo "max-world-size=29999984" >> server.properties

# Accept EULA
RUN echo "eula=true" > eula.txt

# Create startup script
RUN echo '#!/bin/bash' > start.sh && \
    echo 'echo "Starting Minecraft SMP Server..."' >> start.sh && \
    echo 'java ${JAVA_OPTS} -jar ${SERVER_JAR} --nogui' >> start.sh && \
    chmod +x start.sh

# Expose port
EXPOSE 25565

# Create volumes for persistent data
VOLUME ["/minecraft/world", "/minecraft/plugins", "/minecraft/logs"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:25565 || exit 1

# Start the server
CMD ["./start.sh"]