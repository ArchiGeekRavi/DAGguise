#!/bin/bash

if [[ -z "$GEM5_ROOT" ]]; then
    echo "GEM5_ROOT is not set!" 1>&2
    exit 1
fi

if [[ -z "$SPEC_ROOT" ]]; then
    echo "SPEC_ROOT is not set!" 1>&2
    exit 1
fi

cd $GEM5_ROOT/eval_scripts/simu_single/

# Array of SPEC benchmark names  except bwaves, gcc, imagick, mcf, perlbench
spec_benchmarks=(
    "blender_r"
    "cactuBSSN_r"
    "deepsjeng_r"
    "exchange2_r"
    "fotonik3d_r"
    "lbm_r"
    "leela_r"
    "nab_r"
    "namd_r"
    "povray_r"
    "roms_r"
    "wrf_r"
    "x264_r"
    "xz_r"
)

#spec_benchmarks=(
#     "blender_r"
#)

for benchmark in "${spec_benchmarks[@]}"; do
    # Generate runscript for each benchmark
    python3 generate_runscript_all.py ../simu_common/docDist_2cpu_DAGguise_prefetcher.sh "$benchmark"
    #python3 generate_runscript_all.py ../simu_common/docDist_2cpu_regular.sh "$benchmark"
    #python3 generate_runscript_all.py ../simu_common/docDist_2cpu_FSBTA.sh "$benchmark"

    # Change to the benchmark run directory
    run_dir="$SPEC_ROOT/benchspec/CPU/$benchmark/run/run_base_refrate_gem5_se-m64.0000/"
    if [ ! -d "$run_dir" ]; then
        echo "Directory does not exist: $run_dir" 1>&2
        exit 1
    fi

    cd "$run_dir"
    
    # Run the simulation
    bash $GEM5_ROOT/eval_scripts/simu_single/runscript.sh
    
    cd -
done

echo "All simulations completed."

