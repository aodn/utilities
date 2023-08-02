FROM ubuntu:20.04

ARG BUILDER_UID=9999

ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	jq \
	curl \
	python3 \
    python3-pip \
	wget \
	git \
	zip \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

RUN pip install \
	git+https://github.com/aodn/python-github-backup.git@nohooks \
	awscli==1.29.17

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y
	
RUN useradd --create-home --no-log-init --shell /bin/bash --uid $BUILDER_UID builder
USER builder
WORKDIR /home/builder
