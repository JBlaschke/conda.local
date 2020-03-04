#!/usr/bin/env bash


# stop running if there's an error
set -e


#
# Run conda installer locally
#

# set up install path for the local conda path
conda_setup_dir=$(dirname ${BASH_SOURCE[0]})
conda_setup_path=$(readlink -f $conda_setup_dir)
conda_prefix=$conda_setup_path/miniconda3

# run conda installer
$conda_setup_path/Miniconda3-latest-Linux-x86_64.sh -b -p $conda_prefix


#
# update PATH (this is local to the current machine)
#

cat > $conda_setup_path/env.local <<EOF
# Add the local miniconda install to the PATH
if [[ ":\$PATH:" != *$conda_prefix/bin* ]]; then
    export PATH=$conda_prefix/bin:\$PATH
    # Sometimes so junk can be left over in the PYTHONPATH variable => delete it
    export PYTHONPATH=
fi
EOF


#
# This conda install could be outdated => run update
#

source $conda_setup_path/env.local
conda update -y --all -n base -c defaults conda


#
# Install mpi4py
#

if [[ ! -d $conda_setup_dir/tmp ]]; then
    mkdir $conda_setup_dir/tmp
fi

pushd $conda_setup_dir/tmp
# download the mpi4py source 
pip download mpi4py

# figure out the name of the downloaded source
source_name=$(find . -maxdepth 1 -name "mpi4py*" -type f)

# extract source
tar -xvf $source_name

# figure out the name of source dir
source_dir=$(find . -maxdepth 1 -name "mpi4py*" -type d)


pushd $source_dir
# build mpi4py
python setup.py build --mpicc="$(which cc) -shared"
python setup.py install
popd

conda deactivate

# clean up
rm -r $source_dir
rm -r $source_name
popd



echo "Conda is all set up in $conda_prefix"
echo " <- to use this version of conda, run 'source conda/env.local'"
