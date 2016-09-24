FROM node:6.6
MAINTAINER tbenst@gmail.com

EXPOSE 8888

RUN apt-get update && apt-get install -y \
	libzmq3-dev


#### install anaconda ####

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-4.1.1-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH


#### install jupyter kernel for node.js #####

WORKDIR /tmp
RUN git clone https://github.com/notablemind/jupyter-nodejs.git
RUN mkdir -p ~/.ipython/kernels/nodejs/
RUN cd jupyter-nodejs && npm install && node install.js
RUN cd jupyter-nodejs && make
RUN jupyter console --kernel nodejs

# install webppl
RUN npm install -g webppl

RUN mkdir /notebooks
VOLUME /notebooks
WORKDIR /notebooks

CMD jupyter notebook --no-browser --ip=0.0.0.0
