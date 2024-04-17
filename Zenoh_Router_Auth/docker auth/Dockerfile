# Use a base image
FROM eclipse/zenoh

# Set working directory
WORKDIR /zenoh

# Copy configuration files
COPY config.json5 /etc/zenoh/config.json5
COPY entrypoint.sh /entrypoint.sh
COPY credentials.txt /zenoh/credentials.txt

# Make entrypoint.sh executable
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 7447
EXPOSE 8000

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
