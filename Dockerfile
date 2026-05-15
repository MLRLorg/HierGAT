FROM python:3.7.17-buster

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/root/.cache/huggingface \
    TRANSFORMERS_CACHE=/root/.cache/huggingface \
    SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True

WORKDIR /workspace/HierGAT

# Debian Buster está arquivado.
# Ajusta os repositórios para archive.debian.org antes do apt-get update.
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i 's|http://deb.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99archive-check-valid-until

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade \
    pip==20.3.4 \
    setuptools==57.5.0 \
    wheel==0.37.1

COPY requirements.txt .

RUN pip install Cython==0.29.36
RUN pip install torch==1.4.0
RUN pip install -r requirements.txt

COPY . .

RUN mkdir -p checkpoints /root/.cache/huggingface

CMD ["python", "train.py", "--task", "Amazon", "--batch_size", "32", "--max_len", "256", "--lr", "1e-5", "--n_epochs", "10", "--finetuning", "--split", "--lm", "bert"]