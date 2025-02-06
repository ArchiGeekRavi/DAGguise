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
# checkpoint_dir="$SPEC_ROOT/ckpt"

# open policy checkpoint of SPEC
checkpoint_dir="$SPEC_ROOT/ckpt"
merged_dir_prefix="merged_checkpoint_"

#===========================================================================================================
# Two combinations of checkpoints --> SPEC + DOCDIST (closed policy used by DAG and FST) and SPEC + DOCDIST (open policy used by insecure baseline)
#merged_dir_prefix="merged_checkpoint_closed_policy_"
#merged_dir_prefix="merged_checkpoint_open_policy_"
#==========================================================================================================

# Array of SPEC benchmark names
# spec_benchmarks=(
#     "xz_r"
# )

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
victim_checkpoint_docdist="$GEM5_ROOT/checkpoint/docdist/multicore/cpt.1285668711966"
victim_checkpoint_dna="$GEM5_ROOT/checkpoint/dna/multicore/cpt.1764360265758"
# victim_checkpoint_docdist="$GEM5_ROOT/checkpoint/docdist/singlecore/cpt.1285668711966"
# victim_checkpoint_dna="$GEM5_ROOT/checkpoint/dna/singlecore/cpt.1764360265758"

[ ! -d "$victim_checkpoint_docdist" ] && echo "Specified checkpoint doesn't exist! The checkpoint pointer in this script may need to be updated to point to the correct path/tick id." && exit 1

# [ ! -d "$victim_checkpoint_dna" ] && echo "Specified checkpoint doesn't exist! The checkpoint pointer in this script may need to be updated to point to the correct path/tick id." && exit 1


cd "$GEM5_ROOT/checkpoint_merge_multicore/"
# cd "$GEM5_ROOT/checkpoint_merge_singlecore_xz/"

export GEM5_ROOT

# Loop over each SPEC benchmark and create merged checkpoints
for benchmark in "${spec_benchmarks[@]}"; do
    unprotected_checkpoint="$checkpoint_dir/$benchmark/$checkpoint_subpath"
    merged_directory="$merged_dir_prefix$benchmark/cpt.None.SIMP-0"
    
    echo "Merging $benchmark checkpoint with DocDist and DNA checkpoints into $merged_directory..."
    
    mkdir -p "$merged_directory"
    
    # bash generateMerge_multicore.sh "$merged_directory" "$unprotected_checkpoint" "$victim_checkpoint_docdist" "$victim_checkpoint_dna" &
    bash generateMerge_multicore.sh "$merged_directory" "$unprotected_checkpoint" "$victim_checkpoint_docdist" "$victim_checkpoint_dna" &

done

wait

echo "All merges completed."

cd -

