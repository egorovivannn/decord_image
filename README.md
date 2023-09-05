# Dockerfile for decord with GPU support.

Original Dockerfile from decord repo crashs with an error related to libnvcuvid.so files. 

The solution for that is to create a dummy libnvcuvid.so file and copy it to a proper place so that docker can see it during installation.

Dockerfile from this repo installs decord as it should.
