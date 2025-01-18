if [[ -z "$GEM5_ROOT" ]]; then
    echo "GEM5_ROOT is not set!" 1>&2
    exit 1
fi

cd $GEM5_ROOT/sample_programs/mm
make
cd $GEM5_ROOT/checkpoint/mm
source runscript_singlecore.sh
cd -
