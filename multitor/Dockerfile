# Use alpine as the base image
FROM alpine:latest

# Environment variables for package versions or configurations
ENV BUILD_PACKAGES="build-base openssl-dev ca-certificates wget curl git vim" \
    PACKAGES="tor lyrebird webtunnel meek snowflake sudo bash haproxy privoxy procps" \
    PYTHON_PACKAGES="python3 py3-requests py3-pysocks py3-stem py3-flask"

# Install build and runtime packages
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache $BUILD_PACKAGES $PACKAGES $PYTHON_PACKAGES && \
    update-ca-certificates

# Build and install Snowflake Pluggable Transport
# RUN wget -qO /usr/bin/snowflake-client \
#     "https://github.com/PacketCipher/tor-pluggable-snowflake/releases/download/v0.1.0/snowflake-client-linux-amd64-musl" && \
#     chmod +x /usr/bin/snowflake-client

# Build and install Conjure Pluggable Transport
RUN wget -qO /usr/bin/conjure-client \
    "https://github.com/PacketCipher/tor-conjure/releases/download/v0.1.0/conjure-client-linux-amd64-musl" && \
    chmod +x /usr/bin/conjure-client

# Set up application directory
WORKDIR /usr/src/app

# Install multitor
ADD "https://api.github.com/repos/NullRoute-Lab/multitor/commits?per_page=1" /usr/src/latest_commit
RUN git clone https://github.com/PacketCipher/multitor.git .
RUN chmod +x setup.sh && \
    ./setup.sh install && \
    # Create log folders required by multitor
    mkdir -p /var/log/multitor/privoxy/ && \
    # Modify HAProxy template to listen on all interfaces within the container
    # Ensure the path to templates/haproxy-template.cfg is correct relative to WORKDIR
    sed -i 's/127.0.0.1:16379/0.0.0.0:16379/g' templates/haproxy-template.cfg

# Copy the startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Expose the default HAProxy port
EXPOSE 16379

# Set the entrypoint to the startup script
CMD ["/usr/local/bin/startup.sh"]
