#!/usr/bin/env bash

install-mpi4py() {

    if [[ $# -gt 0 ]]; then
        # figure out the name of the static source
        source_name=$(find $1 -maxdepth 1 -name "mpi4py*" -type f)

        echo "Using static source: $source_name"
    else
        # download the mpi4py source 
        pip download mpi4py --no-binary :all:

        # figure out the name of the downloaded source
        source_name=$(find . -maxdepth 1 -name "mpi4py*" -type f)

        echo "Using downloaded source: $source_name"
    fi

    # extract source
    tar -xf $source_name

    # figure out the name of source dir
    source_dir=$(find . -maxdepth 1 -name "mpi4py*" -type d)

    # configure compiler
    if [[ $USE_CC = true ]]; then
        mpicc_str="$(which cc) -shared"
    else
        mpicc_str="$(which mpicc)"
    fi

    pushd $source_dir
    # build mpi4py
    echo "Compiling mpi4py with with --mpicc=$mpicc_str"
    python setup.py build --mpicc="$mpicc_str"
    python setup.py install
    popd


    if [[ $CLEANUP = true ]]; then
        # clean up
        rm -r $source_dir
        rm -r $source_name
    fi
}
