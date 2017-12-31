# Dockerized Bytecoin RPC Wallet

Dockerized Bytecoin RPC Wallet for quick tests through a remote node (without standalone blockchain).

## Running

Get the image:

```
docker pull willianantunes/bytecoin-rpc-wallet
```

Run as a service, exposing port 8070 (JSON RPC server):

```
docker run -d -p 8070:8070 --name bcn-rpc-wallet willianantunes/bytecoin-rpc-wallet
```

See the logs while running:

```
docker exec -it bcn-rpc-wallet /bin/tailf /root/.bytecoin/logs/walletd.log
```