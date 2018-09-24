FROM ubuntu:xenial-20180123
 
USER root

RUN apt-get update \
    && apt-get upgrade --assume-yes \
    && apt-get install -y software-properties-common \
    && apt-add-repository ppa:ansible/ansible \
    && apt-get update \
    && apt-get install --no-install-recommends \
                       --assume-yes \
                       python2.7-minimal=2.7.12* \
                       python-pip=8.1.1-* \
                       unzip=6.0* \
                       wget=1.17.1* \
                       zip=3.0* \
                       ansible \
    && apt-get clean

RUN pip install --no-cache-dir \
    pip==9.0.1 \
    setuptools==38.4.0

RUN pip install --no-cache-dir awscli==1.14.30
