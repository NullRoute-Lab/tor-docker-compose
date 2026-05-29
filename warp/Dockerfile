# Use a lightweight Debian image as the base
FROM debian:bookworm-slim

ARG TARGETARCH

# Install necessary dependencies for warp-plus and tun2socks
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    iproute2 \
    iptables \
    wget \
    bash \
    ca-certificates \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Download and install tun2socks
RUN wget https://github.com/xjasonlyu/tun2socks/releases/download/v2.5.2/tun2socks-linux-${TARGETARCH}.zip \
    && unzip tun2socks-linux-${TARGETARCH}.zip \
    && mv tun2socks-linux-${TARGETARCH} /usr/local/bin/tun2socks \
    && rm tun2socks-linux-${TARGETARCH}.zip

# Download and extract the warp-plus binary
RUN curl -L -o warp-plus.zip https://github.com/bepass-org/warp-plus/releases/download/v1.2.6/warp-plus_linux-${TARGETARCH}.zip \
    && unzip warp-plus.zip \
    && rm warp-plus.zip

# Make the binaries executable
RUN chmod +x warp-plus /usr/local/bin/tun2socks

# Copy the startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose the warp-plus SOCKS5 proxy port
EXPOSE 8086

# Run the startup script
CMD ["/app/start.sh"]