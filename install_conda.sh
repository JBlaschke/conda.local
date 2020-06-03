#!/usr/bin/env bash


# stop running if there's an error
set -e


#
# Run conda installer locally
#

# set up install path for the local conda path
conda_setup_path=$(readlink -f $(dirname ${BASH_SOURCE[0]}))
conda_prefix=$conda_setup_path/miniconda3

# run conda installer
if [[ $USE_PPC = true ]]; then
    $conda_setup_path/Miniconda3-latest-Linux-ppc64le.sh -b -p $conda_prefix
else
    $conda_setup_path/Miniconda3-latest-Linux-x86_64.sh -b -p $conda_prefix
fi


#
# update PATH (this is local to the current machine)
#

cat > $conda_setup_path/env.local <<EOF
#
# Add the local miniconda install to the PATH
# Automaticall generated using install_conda.sh
#


if [[ ":\$PATH:" != *$conda_prefix/bin* ]]; then
    export PATH=$conda_prefix/bin:\$PATH
    # Sometimes so junk can be left over in the PYTHONPATH variable => delete it
    export PYTHONPATH=
fi
# used by unenv.sh
export PATHSTR=$conda_prefix/bin
EOF

#
# This conda install could be outdated => run update
#

source $conda_setup_path/env.local
conda update -y --all -n base -c defaults conda


#
# Install mpi4py
#

if [[ ! $SKIP_MPI4PY = true ]]; then
    source $conda_setup_path/install_mpi4py.sh

    if [[ ! -d $conda_setup_path/tmp ]]; then
        mkdir $conda_setup_path/tmp
    fi

    pushd $conda_setup_path/tmp
    install-mpi4py $STATIC_DIR
    popd
fi


echo "Conda is all set up in $conda_prefix"
echo " <- to use this version of conda, run 'source env.local'"
