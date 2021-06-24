FROM ubuntu:16.04

COPY ./mudracoin.conf /root/.mudracoin/mudracoin.conf

COPY . /mudracoin
WORKDIR /mudracoin

#shared libraries and dependencies
RUN apt update
RUN apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
RUN apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev

#BerkleyDB for wallet support
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install -y libdb4.8-dev libdb4.8++-dev

#upnp
RUN apt-get install -y libminiupnpc-dev

#ZMQ
RUN apt-get install -y libzmq3-dev

#build mudracoin source
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

#Cross-compilation for Ubuntu and Windows Subsystem for Linux
RUN sudo apt update
RUN sudo apt upgrade
RUN sudo apt install build-essential libtool autotools-dev automake pkg-config bsdmainutils curl git
RUN sudo apt install g++-mingw-w64-x86-64

#Building for 64-bit Windows
RUN PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g') # strip out problematic Windows %PATH% imported var
RUN cd depends
RUN make HOST=x86_64-w64-mingw32
RUN cd ..
RUN ./autogen.sh
RUN CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure --prefix=/
RUN make

#open service port
EXPOSE 9191 19191

CMD ["mudracoind", "--printtoconsole"]
