if [[ -z "$GEM5_ROOT" ]]; then
    echo "GEM5_ROOT is not set!" 1>&2
    exit 1
fi

cd $GEM5_ROOT/sample_programs/dna/src
#sed -i.bak "s|DNA_PATH|$(pwd)|g" docDist.cpp
make
cd $GEM5_ROOT/checkpoint/dna/
source runscript_singlecore.sh


