# Use an Ubuntu base image
FROM ubuntu:latest

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y \
    clamav \
    clamav-daemon \
    yara \
    strace \
    tcpdump \
    python3 \
    python3-pip \
    procps \
    net-tools \
    wget \
    iproute2 \
    iputils-ping \
    unzip && \
    freshclam  # Update ClamAV signatures


# Create a directory for the files to be analyzed
RUN mkdir /analysis

# Set the working directory
WORKDIR /analysis

# Script to run the analysis (defined later)
COPY analyze.sh /analyze.sh
RUN chmod +x /analyze.sh

# Entry point to start the analysis script
ENTRYPOINT ["/analyze.sh"]
