FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV CUDNN_VERSION=8.2.0.53-1+cuda11.3
ENV NCCL_VERSION=2.9.9-1+cuda11.3

ENV DEBIAN_FRONTEND="noninteractive" 
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV ML_WORKERS_COUNT=1
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility


ARG python=3.8
ENV PYTHON_VERSION=${python}

SHELL ["/bin/bash", "-cu"]

RUN apt-get -y update && apt-get install -y \
    software-properties-common \
    build-essential \
    checkinstall \
    cmake \
    make \
    pkg-config \
    yasm \
    git \
    vim \
    curl \
    wget \
    sudo \
    apt-transport-https \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    dbus-x11 \
    iputils-ping \
    python3-dev \
    python3-pip \
    python3-setuptools \
    g++-7 \
    ca-certificates

RUN apt-get update && apt-get install -y
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata
RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
    libcudnn8=${CUDNN_VERSION} \
    libnccl2=${NCCL_VERSION} \
    libnccl-dev=${NCCL_VERSION} \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-distutils 

RUN apt-get -y update && apt-get install -y \
    libjpeg8-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2-dev \
    libavfilter-dev  \
    libavutil-dev \
    librdmacm1 \
    libibverbs1 \
    ibverbs-providers 


RUN apt-get -y update && apt-get install -y ffmpeg  
RUN ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python


RUN python3 -m pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113

COPY cuda_files/libnvcuvid.so /usr/local/cuda/lib64/stubs

RUN git clone --recursive https://github.com/dmlc/decord
WORKDIR /decord
RUN mkdir build

WORKDIR /decord/build
RUN cmake .. -DUSE_CUDA=ON -DCMAKE_BUILD_TYPE=Release
RUN make
RUN cd ../python && python3 setup.py install --user

RUN apt-get clean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* && apt-get -y autoremove

WORKDIR /root
