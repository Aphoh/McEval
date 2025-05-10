# Use a specific Ubuntu version for reproducibility
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install common dependencies and build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    curl \
    wget \
    tar \
    gzip \
    unzip \
    zip \
    git \
    vim \
    && \
    rm -rf /var/lib/apt/lists/*

# --- Language Specific Installations ---

# Python (Python3 is usually default on recent Ubuntu and included in build-essential deps)

# Node.js and npm (for JS, TS, CoffeeScript)
# Using NodeSource repository for a specific version (Node.js 18.x LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install global npm packages as specified
RUN npm install -g typescript coffee-script

# Java (for Java, Kotlin, Groovy)
# Install OpenJDK 11 as a common LTS version
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-11-jdk && \
    rm -rf /var/lib/apt/lists/*

# Kotlin (Install via apt if available, might be older version)
RUN apt-get update && \
    apt-get install -y --no-install-recommends kotlin && \
    rm -rf /var/lib/apt/lists/*

# Groovy (Requires Java, manual download as specified)
ENV GROOVY_VERSION=4.0.26
RUN wget https://groovy.jfrog.io/artifactory/dist-release-local/groovy-zips/apache-groovy-docs-${GROOVY_VERSION}.zip -O /tmp/groovy.zip && \
    unzip /tmp/groovy.zip -d /opt/ && \
    rm /tmp/groovy.zip
ENV PATH="/opt/apache-groovy-sdk-${GROOVY_VERSION}/bin:${PATH}"

# Go
RUN apt-get update && \
    apt-get install -y --no-install-recommends golang && \
    rm -rf /var/lib/apt/lists/*

# Rust (Using rustup script as specified - note: less ideal for reproducible Docker builds than official images or manual download)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Fortran
RUN apt-get update && \
    apt-get install -y --no-install-recommends gfortran && \
    rm -rf /var/lib/apt/lists/*

# C-sharp / F# / Vb (.NET SDK)
# Using Microsoft's official repository for .NET 8.0 SDK
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    rm /tmp/packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends dotnet-sdk-8.0 fsharp && \
    rm -rf /var/lib/apt/lists/*

# Scala (Using Coursier script as specified)
RUN curl -fL https://github.com/coursier/coursier/releases/download/v2.1.23/cs-x86_64-pc-linux.gz | gzip -d > /usr/local/bin/cs && \
    chmod +x /usr/local/bin/cs && \
    cs setup --yes
ENV PATH="/root/.local/share/coursier/bin:${PATH}"

# Php
RUN apt-get update && \
    apt-get install -y --no-install-recommends php php-cli && \
    rm -rf /var/lib/apt/lists/*
# Note: The provided instructions mention modifying php.ini for assert.
# The exact path and required modification depend on your specific needs and PHP version.
# You might need to add a step here using 'sed' or copying a custom php.ini.
# Example (uncomment and adjust path/setting as needed):
# RUN sed -i 's/assert.exception=0/assert.exception=1/' $(php --ini | grep "Loaded Configuration File" | sed -e "s/.*:\s*//")

# Dart (Manual download based on common practice, using version from pubspec example)
ENV DART_VERSION=3.2.0
RUN wget https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip -O /tmp/dartsdk.zip && \
    unzip /tmp/dartsdk.zip -d /opt/ && \
    rm /tmp/dartsdk.zip
ENV PATH="/opt/dart-sdk/bin:${PATH}"

# Pascal (Free Pascal Compiler)
RUN apt-get update && \
    apt-get install -y --no-install-recommends fpc && \
    rm -rf /var/lib/apt/lists/*

# Julia (Manual download as specified, using version from instruction)
ENV JULIA_VERSION=1.9.4
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz -O /tmp/julia.tar.gz && \
    tar -xzf /tmp/julia.tar.gz -C /opt/ && \
    rm /tmp/julia.tar.gz
ENV PATH="/opt/julia-${JULIA_VERSION}/bin:${PATH}"

# Ruby
RUN apt-get update && \
    apt-get install -y --no-install-recommends ruby-full && \
    rm -rf /var/lib/apt/lists/*

# Lua (Using apt package)
RUN apt-get update && \
    apt-get install -y --no-install-recommends lua5.4 && \
    rm -rf /var/lib/apt/lists/*

# Haskell (Using apt packages ghc and cabal-install)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ghc cabal-install && \
    rm -rf /var/lib/apt/lists/*

# Tcl
RUN apt-get update && \
    apt-get install -y --no-install-recommends tcl && \
    rm -rf /var/lib/apt/lists/*

# Scheme / Racket
RUN apt-get update && \
    apt-get install -y --no-install-recommends racket && \
    rm -rf /var/lib/apt/lists/*

# Zig (Manual download as specified, using version from instruction)
ENV ZIG_VERSION=0.14.0
RUN wget https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz -O /tmp/zig.tar.xz && \
    tar -xvf /tmp/zig.tar.xz -C /opt/ && \
    rm /tmp/zig.tar.xz
ENV PATH="/opt/zig-linux-x86_64-${ZIG_VERSION}:${PATH}"

# Powershell
RUN apt-get update && \
    apt-get install -y --no-install-recommends powershell && \
    rm -rf /var/lib/apt/lists/*

# Tcsh
RUN apt-get update && \
    apt-get install -y --no-install-recommends csh && \
    rm -rf /var/lib/apt/lists/*

# R
RUN apt-get update && \
    apt-get install -y --no-install-recommends r-base && \
    rm -rf /var/lib/apt/lists/*

# Elisp (Emacs - installing the no-GUI version)
RUN apt-get update && \
    apt-get install -y --no-install-recommends emacs-nox && \
    rm -rf /var/lib/apt/lists/*

# Erlang
RUN apt-get update && \
    apt-get install -y --no-install-recommends erlang && \
    rm -rf /var/lib/apt/lists/*

# Awk (Usually included in base image)

# Elixir
RUN apt-get update && \
    apt-get install -y --no-install-recommends elixir && \
    rm -rf /var/lib/apt/lists/*

# Clisp (SBCL)
RUN apt-get update && \
    apt-get install -y --no-install-recommends sbcl && \
    rm -rf /var/lib/apt/lists/*

# Swift (Manual download as specified, using a recent stable version)
ENV SWIFT_VERSION=5.9.2
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    clang \
    libcurl4-openssl-dev \
    libicu-dev \
    libbsd-dev \
    libblocksruntime-dev \
    && \
    rm -rf /var/lib/apt/lists/*
RUN SWIFT_URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2204/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu22.04.tar.gz" && \
    wget ${SWIFT_URL} -O /tmp/swift.tar.gz && \
    tar -xzf /tmp/swift.tar.gz -C /opt/ && \
    rm /tmp/swift.tar.gz
ENV PATH="/opt/swift-${SWIFT_VERSION}-RELEASE-ubuntu22.04/usr/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common
RUN add-apt-repository universe
RUN apt-get install -y --no-install-recommends python3-bs4

# Clean up apt cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Set the working directory
WORKDIR /workspace

# Optional: Set a default command to keep the container running or start a shell
# CMD ["bash"]