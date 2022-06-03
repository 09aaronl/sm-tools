[![Docker Repository on Quay](https://quay.io/repository/aelin/sm-tools/status "Docker Repository on Quay")](https://quay.io/repository/aelin/sm-tools)

# sm-tools
This repo contains the Docker files needed to build the image `quay.io/aelin/sm-tools`. This image is based on the ubuntu
image `quay.io/broadinstitute/viral-baseimage:0.1.15` and contains tools for experimentally guided RNA structure prediction.

 - read processing: shapemapper2
 - structure prediction: Superfold, RNAstructure

To build, run `docker build .` from within the directory containing the `Dockerfile`.