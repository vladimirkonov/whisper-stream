FROM ghcr.io/astral-sh/uv:python3.10-bookworm
#FROM nvidia/cuda:9.0.0-runtime-ubuntu20.04
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV DEBIAN_FRONTEND=noninteractive

RUN uv python install 3.10

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    ffmpeg \
    curl \
    sudo \
    git \
    wget

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
RUN sudo dpkg -i cuda-keyring_1.1-1_all.deb
RUN sudo apt-get update -y \
    && sudo apt-get -y install cudnn

RUN mkdir app
COPY . /app/

WORKDIR app

RUN uv sync --extra cu124 --frozen
RUN uv cache clean

EXPOSE 8000

ENTRYPOINT ["uv", "run", "python", "whisper_fastapi_online_server.py", "--host", "0.0.0.0", "--port", "8000", "--backend", "faster-whisper"]

CMD ["--model", "large-v3-turbo"]
