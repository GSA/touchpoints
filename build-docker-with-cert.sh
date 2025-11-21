#!/bin/bash

# Script to build Docker image with optional Zscaler certificate

set -e

echo "Building Docker image for CircleCI with Zscaler certificate support..."

# Create a temporary build context
BUILD_DIR=$(mktemp -d)
echo "Using temporary build directory: $BUILD_DIR"

# Copy all files to build context
cp -r . "$BUILD_DIR/"
cd "$BUILD_DIR"

# Check if Zscaler certificate exists in various common locations
CERT_FOUND=false
CERT_LOCATIONS=(
    "./zscaler-cert.crt"
    "./zscaler-root-ca.crt"
    "./ZscalerRootCertificate-2048-SHA256.crt"
    "$HOME/.zscaler/zscaler-cert.crt"
    "/usr/local/share/ca-certificates/zscaler-cert.crt"
    "/etc/ssl/certs/zscaler-cert.crt"
)

echo "Searching for Zscaler certificate..."
for cert_path in "${CERT_LOCATIONS[@]}"; do
    if [ -f "$cert_path" ]; then
        echo "Found Zscaler certificate at: $cert_path"
        if [ "$cert_path" != "./zscaler-cert.crt" ]; then
            cp "$cert_path" "./zscaler-cert.crt"
        fi
        CERT_FOUND=true
        break
    fi
done

if [ "$CERT_FOUND" = false ]; then
    echo "No Zscaler certificate found. Creating placeholder file..."
    echo "# No Zscaler certificate provided" > zscaler-cert.crt
fi

# Create a modified Dockerfile that handles the certificate conditionally
cat > Dockerfile.circleci.tmp << 'EOF'
FROM ruby:3.2.8-slim

# Update packages and install dependencies including certificate tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    curl \
    wget \
    gnupg2 \
    software-properties-common \
    ca-certificates \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy certificate file (might be placeholder)
COPY zscaler-cert.crt /tmp/zscaler-cert.crt

# Add Zscaler certificate to system store if it's a valid certificate
RUN if openssl x509 -in /tmp/zscaler-cert.crt -text -noout >/dev/null 2>&1; then \
        echo "Adding Zscaler certificate to system store..."; \
        cp /tmp/zscaler-cert.crt /usr/local/share/ca-certificates/zscaler-cert.crt; \
        update-ca-certificates; \
        echo "Zscaler certificate added successfully"; \
    else \
        echo "No valid Zscaler certificate found, using default certificates"; \
        update-ca-certificates; \
    fi && \
    rm /tmp/zscaler-cert.crt

# Configure SSL settings for various tools
RUN echo 'export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt' >> /etc/environment && \
    echo 'export SSL_CERT_DIR=/etc/ssl/certs' >> /etc/environment

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Install Cloud Foundry CLI
RUN curl -v -L -o cf-cli_amd64.deb 'https://packages.cloudfoundry.org/stable?release=debian64&source=github' \
    && dpkg -i cf-cli_amd64.deb \
    && rm cf-cli_amd64.deb

# Create circleci user and group
RUN groupadd --gid 3434 circleci \
    && useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci

USER circleci
WORKDIR /home/circleci/repo

# Set environment variables
ENV RAILS_ENV=test
ENV PGHOST=db
ENV PGUSER=postgres
ENV REDIS_URL=redis://redis:6379/1
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_DIR=/etc/ssl/certs

# Copy application files
COPY --chown=circleci:circleci . .

# Install gems with SSL configuration
RUN bundle install

# Install npm packages
RUN npm install

# Create test results directory
RUN mkdir -p /tmp/test-results

# Default command runs the CircleCI test steps
CMD ["bash", "-c", "bundle exec rake db:create && bundle exec rake db:schema:load && rails assets:precompile && bundle exec rspec --format progress --format RspecJunitFormatter --out /tmp/test-results/rspec.xml --format progress spec/"]
EOF

# Build the Docker image
echo "Building Docker image..."
docker build -f Dockerfile.circleci.tmp -t touchpoints-circleci:latest .

# Clean up
cd /
rm -rf "$BUILD_DIR"

echo "Docker image built successfully!"
echo ""
echo "To run the container:"
echo "  docker run --rm -it touchpoints-circleci:latest bash"
echo ""
echo "To run CircleCI locally with the new image:"
echo "  circleci local execute --docker-image touchpoints-circleci:latest"