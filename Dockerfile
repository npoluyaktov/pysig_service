FROM ubuntu:23.10
ARG SIG_PIN
ENV SIG_PIN=$SIG_PIN
ARG CONT='\\.\HDIMAGE\ca9e858e6-4a61-c61a-159e-e750ff4c00b'
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
    /opt/cprocsp/bin/amd64/certmgr -inst -store mMy -thumbprint 9665de1cb14ce98a15bf9217add65560b5350860 -file /app/test.cer -cont ${CONT} -pin 1234567890
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