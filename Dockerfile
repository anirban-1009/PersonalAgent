# Use a Python base image with support for audio processing
FROM python:3.11-slim

# Install system dependencies for audio and faster-whisper
RUN apt-get update && apt-get install -y \
    ffmpeg \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install uv for fast dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-cache

# Copy the rest of the application
COPY . .

# Environment variables for LiveKit connection
# Using host.docker.internal to connect to the LiveKit server running on your machine
ENV LIVEKIT_URL=ws://host.docker.internal:7880
ENV LIVEKIT_API_KEY=devkey
ENV LIVEKIT_API_SECRET=secret

# Run the agent (assuming the entry point is agent.py)
CMD ["uv", "run", "python", "agent.py", "dev"]
