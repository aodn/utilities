FROM ubuntu:16.04

ARG BUILDER_UID=9999
ARG PACKER_VERSION=1.4.2

ENV LANG C.UTF-8
ENV PATH /opt/packer:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	jq \
	curl \
	python3 \
	wget\
	git \
	zip \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

RUN wget -q https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py pip==18.1 \
    && rm -rf get-pip.py

RUN pip install \
	github-backup==0.33.0 \
	awscli==1.18.39
	
RUN useradd --create-home --no-log-init --shell /bin/bash --uid $BUILDER_UID builder
USER builder
WORKDIR /home/builder
