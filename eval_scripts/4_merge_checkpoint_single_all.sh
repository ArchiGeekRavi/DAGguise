#!/bin/bash

if [[ -z "$GEM5_ROOT" ]]; then
    echo "GEM5_ROOT is not set!" 1>&2
    exit 1
fi

if [[ -z "$SPEC_ROOT" ]]; then
    echo "SPEC_ROOT is not set!" 1>&2
    exit 1
fi

# Common paths and identifiers
checkpoint_subpath="cpt.None.SIMP-50000000/"
#checkpoint_subpath="cpt.None.SIMP-25000000000/"

# closed policy checkpoint of SPEC
checkpoint_dir="$SPEC_ROOT/ckpt"

# open policy checkpoint of SPEC
checkpoint_dir="$SPEC_ROOT/ckpt"
merged_dir_prefix="merged_checkpoint_"

#===========================================================================================================
# Two combinations of checkpoints --> SPEC + DOCDIST (closed policy used by DAG and FST) and SPEC + DOCDIST (open policy used by insecure baseline)
#merged_dir_prefix="merged_checkpoint_closed_policy_"
#merged_dir_prefix="merged_checkpoint_open_policy_"
#==========================================================================================================

# Array of SPEC benchmark names
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

# Change if desired
victim_checkpoint="$GEM5_ROOT/checkpoint/docdist/cpt.1293351707616/"

[ ! -d "$victim_checkpoint" ] && echo "Specified checkpoint doesn't exist! The checkpoint pointer in this script may need to be updated to point to the correct path/tick id." && exit 1

cd "$GEM5_ROOT/checkpoint_merge/"

export GEM5_ROOT

# Loop over each SPEC benchmark and create merged checkpoints
for benchmark in "${spec_benchmarks[@]}"; do
    unprotected_checkpoint="$checkpoint_dir/$benchmark/$checkpoint_subpath"
    merged_directory="$merged_dir_prefix$benchmark/cpt.None.SIMP-0"
    
    echo "Merging $benchmark checkpoint with DocDist checkpoint into $merged_directory..."
    
    mkdir -p "$merged_directory"
    
    bash generateMerge_single.sh "$merged_directory" "$unprotected_checkpoint" "$victim_checkpoint" &
done

wait

echo "All merges completed."

cd -

