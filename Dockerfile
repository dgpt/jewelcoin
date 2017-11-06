FROM ubuntu:17.10

ENV SRC_DIR /usr/local/src/jewelcoin

RUN set -x \
  && buildDeps=' \
      ca-certificates \
      cmake \
      g++ \
      git \
      libboost-all-dev \
      libssl-dev \
      make \
      pkg-config \
      libzmq3-dev \
  ' \
  && apt-get -qq update \
  && apt-get -qq --no-install-recommends install $buildDeps

RUN git clone https://github.com/dgpt/jewelcoin $SRC_DIR
WORKDIR $SRC_DIR

# TODO: static is failing locally
# is this necessary?
#RUN make -j$(nproc) release-static
RUN make

RUN cp build/release/bin/* /usr/local/bin/ \
  \
  && rm -r $SRC_DIR \
  && apt-get -qq --auto-remove purge $buildDeps

# Contains the blockchain
VOLUME /root/.jewelchain

# Generate your wallet via accessing the container and run:
# cd /wallet
# monero-wallet-cli
VOLUME /wallet

ENV LOG_LEVEL 0
ENV P2P_BIND_IP 0.0.0.0
ENV P2P_BIND_PORT 18880
ENV RPC_BIND_IP 127.0.0.1
ENV RPC_BIND_PORT 18881

EXPOSE 18880
EXPOSE 18881

CMD jewelcoind --log-level=$LOG_LEVEL --p2p-bind-ip=$P2P_BIND_IP --p2p-bind-port=$P2P_BIND_PORT --rpc-bind-ip=$RPC_BIND_IP --rpc-bind-port=$RPC_BIND_PORT
