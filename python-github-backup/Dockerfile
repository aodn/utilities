FROM ubuntu:16.04

ARG BUILDER_UID=9999
ARG PACKER_VERSION=1.4.2

ENV LANG C.UTF-8
ENV PATH /opt/packer:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	jq \
	curl \
	python \
	wget\
	git \
	zip \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py pip==18.1 \
    && rm -rf get-pip.py
	
RUN pip install \
	"git+https://github.com/aodn/utilities.git#egg=github-backup&subdirectory=python-github-backup" \
	awscli==1.18.39
	
RUN useradd --create-home --no-log-init --shell /bin/bash --uid $BUILDER_UID builder
USER builder
WORKDIR /home/builder
