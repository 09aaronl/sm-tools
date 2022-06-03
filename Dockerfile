FROM quay.io/broadinstitute/viral-baseimage:0.1.15

# Largely borrowed from https://github.com/broadinstitute/viral-ngs/blob/master/Dockerfile

LABEL maintainer "aelin@princeton.edu"

# to build:
#   docker build . 
#
# to run:
#   docker run --rm <image_ID> "<command>.py subcommand"
#
# to run interactively:
#   docker run --rm -it <image_ID>

ENV \
	INSTALL_PATH="/opt/sm-tools" \
	SMTOOLS_PATH="/opt/sm-tools/source" \
	MINICONDA_PATH="/opt/miniconda" \
	CONDA_DEFAULT_ENV="sm-tools-env" \
	SHAPEMAPPER2_PATH="/opt/shapemapper" \
	SUPERFOLD_PATH="/opt/superfold" \
	CONDA_DEFAULT_ENV=sm-tools-env

ENV \
	PATH="$SHAPEMAPPER2_PATH:$SHAPEMAPPER2_PATH/internals/bin:$MINICONDA_PATH/bin:$SMTOOLS_PATH/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
	CONDA_PREFIX="$MINICONDA_PATH/envs/$CONDA_DEFAULT_ENV" \
	JAVA_HOME="$MINICONDA_PATH"

# Prepare sm-tools user and installation directory
# Set it up so that this slow & heavy build layer is cached
# unless the requirements* files or the install scripts actually change
WORKDIR $INSTALL_PATH
RUN conda update -n base -c defaults conda
RUN conda create -n $CONDA_DEFAULT_ENV
RUN echo "source activate $CONDA_DEFAULT_ENV" > ~/.bashrc
RUN hash -r
COPY ./ $SMTOOLS_PATH/
RUN $SMTOOLS_PATH/docker/install-sm-tools.sh

RUN /bin/bash -c "set -e; echo -n 'version: '; shapemapper --version"

CMD ["/bin/bash"]