# Use an official NVIDIA CUDA base image
FROM nvidia/cuda:11.2.2-base-ubuntu20.04

# Set a non-root user for security purposes
ARG USER_ID=1000
ARG GROUP_ID=1000

# Install necessary packages
RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create a user and group
RUN groupadd -g ${GROUP_ID} appuser && \
    useradd -r -u ${USER_ID} -g appuser appuser

# Set up working directory
WORKDIR /app

# Copy the source code into the container
COPY . /app/

# Build the rpc-server with CUDA backend
RUN mkdir build-rpc-cuda && cd build-rpc-cuda \
    && cmake .. -DLLAMA_CUDA=ON -DLLAMA_RPC=ON \
    && cmake --build . --config Release

# Switch to the non-root user
USER appuser

# Expose the port the rpc-server will run on
EXPOSE 50052

# Run the rpc-server on container start
CMD ["./build-rpc-cuda/bin/rpc-server", "-p", "50052"]
