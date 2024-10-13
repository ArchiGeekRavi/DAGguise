#!/bin/bash

$GEM5_ROOT/build/X86/gem5.opt \
        --outdir=/home/user/DAGguise/eval_scripts/simu_simple/results/docDist_2cpu_DAGguise_prefetcher/stride_prefetcher/xz_r \
	$GEM5_ROOT/configs/example/se.py \
	--cpu-type=DerivO3CPU \
	--num-cpus=2 \
	--mem-type=DRAMSim2 \
	--caches --l1d_size=32kB --l1i_size=32kB \
        --l1d_assoc=8 --l1i_assoc=8 \
	--l1d-hwp-type=StridePrefetcher \
	--l2cache --l3cache \
	--l2_size=256kB --l2_assoc=16 \
	--l3_size=2MB --l3_assoc=16 \
        --cpu-clock=2.4GHz --sys-clock=2.4GHz \
        --checkpoint-restore=1 --at-instruction --maxinsts=50000000 --warmup-insts=1000000 --standard-switch=1000000 \
	--mem-size=4GB --enabledramlog \
        --dramdeviceconfigfile=$GEM5_ROOT/ext/dramsim2/DRAMSim2/ini/DDR3_micron_32M_8B_x8_sg125.ini \
        --dramsystemconfigfile=$GEM5_ROOT/ext/dramsim2/DRAMSim2/configs/system_dag_multi_closedrow.ini \
        --dagprotectionfile=";$GEM5_ROOT/dag_generator/defense.json" \
	-c "$GEM5_ROOT/sample_programs/docdist/docDist" \
	--checkpoint-dir=/home/user/DAGguise/checkpoint_merge/merged_checkpoint_xz_r/\
	--benchmark=xz_r \
	--simpt-ckpt=0 \
	--dramsim2outputfile=/home/user/DAGguise/eval_scripts/simu_simple/results/docDist_2cpu_DAGguise_prefetcher/stride_prefetcher/xz_r/dram \
