FROM ubuntu:16.04
MAINTAINER Pablo Rotem <pablorotem8@gmail.com>

WORKDIR /tmp
ENV selacoinVersion=1.0.0

ARG containerFile=container-file-selacoin
ENV envContainerFile=$containerFile
ARG containerPassword=container-password-selacoin
ENV envContainerPassword=$containerPassword
ARG daemonAddress=162.243.161.203
ENV envDaemonAddress=$daemonAddress
ARG daemonPort=80
ENV envDaemonPort=$daemonPort
ARG bindAddress=0.0.0.0
ENV envBindAddress=$bindAddress
ARG bindPort=8070
ENV envBindPort=$bindPort
ARG logLevel=5
ENV envLogLevel=$logLevel

RUN apt-get update -y -qq && apt upgrade -y -qq
RUN apt-get install -y -qq sudo curl git vim htop wget bzip2 screen net-tools \
	&& rm -rf /var/lib/apt/lists/*
RUN sudo apt-get install libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libdb-dev libdb++-dev libminiupnpc-dev

RUN wget https://sela-coin.com/download/tools/selacoin-daemon-linux.tar.gz

RUN tar -xvzf selacoin-daemon-linux.tar.gz \
	&& rm -f selacoin-daemon-linux.tar.gz \
	&& mkdir -p ~/.selacoin/ \
	&& mv selacoin-daemon-linux/* ~/.selacoin/ \
	&& rm -rf ./*

WORKDIR /root/.selacoin

RUN ./walletd --container-file=${envContainerFile} --container-password=${envContainerPassword} --generate-container \
	&& mkdir configs logs \
	&& mv ./${envContainerFile} configs/

# https://docs.docker.com/engine/admin/logging/view_container_logs/
# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /root/.selacoin/logs/walletd.log

EXPOSE ${envBindPort}	
	
ENTRYPOINT ./walletd \
	--log-file=/root/.selacoin/logs/walletd.log \
	--container-file=/root/.selacoin/${envContainerFile} \
	--container-password=${envContainerPassword} \
	--daemon-address=${envDaemonAddress} \
	--daemon-port=${envDaemonPort} \
	--bind-address=${envBindAddress} \
	--bind-port=${envBindPort} \
	--log-level=${envLogLevel}
