FROM ubuntu:16.04
MAINTAINER Willian Antunes <willian.lima.antunes@gmail.com>

WORKDIR /tmp
ENV bytecoinVersion=2.1.2

ARG containerFile=container-file-abudegado
ENV envContainerFile=$containerFile
ARG containerPassword=container-password-abudegado
ENV envContainerPassword=$containerPassword
ARG daemonAddress=node.bytecoin.ninja
ENV envDaemonAddress=$daemonAddress
ARG daemonPort=8081
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
RUN wget https://bytecoin.org/storage/wallets/bytecoin_rpc_wallet/rpc-wallet-${bytecoinVersion}-linux.tar.gz
RUN tar -xvzf rpc-wallet-${bytecoinVersion}-linux.tar.gz \
	&& rm -f rpc-wallet-${bytecoinVersion}-linux.tar.gz \
	&& mkdir -p ~/.bytecoin/ \
	&& mv rpc-wallet-${bytecoinVersion}-linux/* ~/.bytecoin/ \
	&& rm -rf ./*

WORKDIR /root/.bytecoin

RUN ./walletd --container-file=${envContainerFile} --container-password=${envContainerPassword} --generate-container \
	&& mkdir configs logs \
	&& mv ./${envContainerFile} configs/

# https://docs.docker.com/engine/admin/logging/view_container_logs/
# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /root/.bytecoin/logs/walletd.log

EXPOSE ${envBindPort}	
	
ENTRYPOINT ./walletd \
	--log-file=/root/.bytecoin/logs/walletd.log \
	--container-file=/root/.bytecoin/configs/${envContainerFile} \
	--container-password=${envContainerPassword} \
	--daemon-address=${envDaemonAddress} \
	--daemon-port=${envDaemonPort} \
	--bind-address=${envBindAddress} \
	--bind-port=${envBindPort} \
	--log-level=${envLogLevel}