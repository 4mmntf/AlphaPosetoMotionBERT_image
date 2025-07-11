# MotionBERT Dockerfile with uv for Python management
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# システムパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    cmake \
    pkg-config \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgfortran5 \
    libyaml-dev \
    ffmpeg \
    neovim \
    && rm -rf /var/lib/apt/lists/*

# uvのインストール
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"

# 作業ディレクトリの設定
WORKDIR /workspace

# MotionBERTとAlphaPoseリポジトリのクローン
RUN git clone https://github.com/Walter0807/MotionBERT.git ./MotionBERT
RUN git clone https://github.com/MVIG-SJTU/AlphaPose.git ./AlphaPose
RUN export PATH=/usr/local/cuda/bin/:$PATH
RUN export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH
RUN uv python install 3.12.5

RUN uv init --python 3.12.5

#RUN echo [tool.uv] >> pyproject.toml
#RUN echo no-build-isolation-package = ["chumpy"] >> pyproject.toml

COPY requirements.txt /workspace/requirements.txt
#RUN uv add -r ./requirements.txt
RUN uv sync

CMD ["bash", "-c", "echo 'Container started'; exec bash"]
