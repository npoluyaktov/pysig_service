FROM ubuntu:23.10
ARG SIG_PIN
ENV SIG_PIN=$SIG_PIN
WORKDIR /app
COPY . .
RUN apt update &&\
    apt install -y python3 python3-pip python3-venv git &&\
    apt install -y cmake build-essential libboost-all-dev python3-dev unzip &&\
    tar xvf linux-amd64_deb.tgz
WORKDIR linux-amd64_deb
RUN ./install.sh &&\
    apt install ./lsb-cprocsp-devel_5.0*.deb &&\
    apt install ./cprocsp-pki-cades*.deb
RUN cp -r /app/ca9e858e.000 /var/opt/cprocsp/keys/root &&\
    /opt/cprocsp/bin/amd64/csptest -keyset -enum_cont -fqcn -verifycontext &&\
    /opt/cprocsp/bin/amd64/certmgr -inst -store mroot -file /app/certnew.cer &&\
    /opt/cprocsp/bin/amd64/certmgr -inst -store mroot -file /app/certnew.cer
WORKDIR /app
RUN git clone https://github.com/CryptoPro/pycades.git
WORKDIR pycades
RUN mkdir build &&\
    cd build &&\
    cmake .. &&\
    make -j4
WORKDIR /app
RUN python3 -m venv def
RUN def/bin/pip install -r requirements.txt
CMD ["def/bin/python", "main.py"]