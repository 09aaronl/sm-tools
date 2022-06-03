#!/bin/bash
#
# This script requires INSTALL_PATH (typically /opt/sm-tools),
# SMTOOLS_PATH (typically /opt/sm-tools/source), and
# MINICONDA_PATH (typically /opt/miniconda) to be set.
#
# A miniconda install must exist at $CONDA_DEFAULT_ENV
# and $CONDA_DEFAULT_ENV/bin must be in the PATH
#
# Otherwise, this only requires the existence of the following files:
#	requirements-git.txt
#	requirements-URL.txt
#	requirements-py2.txt

set -e -o pipefail

echo "PATH:              ${PATH}"
echo "INSTALL_PATH:      ${INSTALL_PATH}"
echo "CONDA_PREFIX:      ${CONDA_PREFIX}"
echo "SMTOOLS_PATH:      ${SMTOOLS_PATH}"
echo "MINICONDA_PATH:    ${MINICONDA_PATH}"
echo "SHAPEMAPPER2_PATH: ${SHAPEMAPPER2_PATH}"
echo "SUPERFOLD_PATH:    ${SUPERFOLD_PATH}"
echo "CONDA_DEFAULT_ENV: ${CONDA_DEFAULT_ENV}"

CONDA_CHANNEL_STRING="--override-channels -c conda-forge -c bioconda"

# setup/install sm-tools directory tree and conda dependencies
sync

# download and unpacks .tar.gz files from URLs
while read url; do
	IFS='=' read -r -a array <<< "$url"
	base_tgz=$(basename "${array[2]}")
	base_name=${base_tgz%.*.*}
	cd /opt/
	wget "${array[2]}"
	tar -xf $base_tgz
	mv $base_name "${array[0]}"
done < "$SMTOOLS_PATH/requirements-URL.txt"

# clone git repos
while read repo; do
	IFS='=' read -r -a array <<< "$repo"
	git clone "${array[2]}" /opt/"${array[0]}"
done < "$SMTOOLS_PATH/requirements-git.txt"
chmod +x $SUPERFOLD_PATH/*.py

# create a python2.7 environment, venv_py27, and set up .sh scripts that execute when 'conda activate venv_py27' is run
conda create --name venv_py27 python=2.7 -y
mkdir -p $MINICONDA_PATH/envs/venv_py27/etc/conda/activate.d/
mkdir -p $MINICONDA_PATH/envs/venv_py27/etc/conda/deactivate.d/
echo '#!/bin/sh' >> $MINICONDA_PATH/envs/venv_py27/etc/conda/activate.d/env_vars.sh
echo "export PATH=$SUPERFOLD_PATH:"'$PATH' >> $MINICONDA_PATH/envs/venv_py27/etc/conda/activate.d/env_vars.sh
echo "export DATAPATH=$MINICONDA_PATH/envs/venv_py27/share/rnastructure/data_tables" >> $MINICONDA_PATH/envs/venv_py27/etc/conda/activate.d/env_vars.sh
echo '#!/bin/sh' >> $MINICONDA_PATH/envs/venv_py27/etc/conda/deactivate.d/env_vars.sh
echo "export PATH=$(echo $PATH | sed s=$SUPERFOLD_PATH:==g)" >> $MINICONDA_PATH/envs/venv_py27/etc/conda/deactivate.d/env_vars.sh
echo 'unset DATAPATH' >> $MINICONDA_PATH/envs/venv_py27/etc/conda/deactivate.d/env_vars.sh
chmod +x $MINICONDA_PATH/envs/venv_py27/etc/conda/activate.d/env_vars.sh $MINICONDA_PATH/envs/venv_py27/etc/conda/deactivate.d/env_vars.sh

# install Superfold (python2.7) dependencies
conda install -y \
	-q $CONDA_CHANNEL_STRING \
	--file "$SMTOOLS_PATH/requirements-py2.txt" \
	-p "$MINICONDA_PATH/envs/venv_py27"

# clean up
conda clean -y --all