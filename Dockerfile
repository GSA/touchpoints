FROM ruby:3.4.7-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs \
    git \
    ca-certificates \
    libyaml-dev \
    curl \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy Zscaler certificate if it exists (needs to be before Rust install)
COPY zscaler-cert.crt /tmp/zscaler-cert.crt
RUN if [ -f /tmp/zscaler-cert.crt ]; then \
    openssl x509 -in /tmp/zscaler-cert.crt -text -noout >/dev/null 2>&1 && \
    cp /tmp/zscaler-cert.crt /usr/local/share/ca-certificates/ && \
    update-ca-certificates; \
    fi

# Install Rust and add to PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    . "$HOME/.cargo/env" && \
    rustc --version && \
    cargo --version

ENV PATH="/root/.cargo/bin:${PATH}" \
    RUSTUP_HOME="/root/.rustup" \
    CARGO_HOME="/root/.cargo"

RUN gem install bundler:2.3.8

WORKDIR /usr/src/app

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 3002

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
