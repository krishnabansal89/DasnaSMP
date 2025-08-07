# Minecraft SMP Server Dockerfile
FROM eclipse-temurin:17-jre-alpine

# Install necessary packages
RUN apk add --no-cache \
    wget \
    curl \
    bash \
    ncurses

# Create minecraft user and directory
RUN adduser -D -u 1000 minecraft
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
    CMD echo "ping" | nc localhost 25565 || exit 1

# Start the server
CMD ["./start.sh"]