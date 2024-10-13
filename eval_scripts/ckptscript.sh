#!/bin/bash

#### LOAD ENV #####
#source /home/gsaileshwar/rowhammer_defense/aqua_gem5/gem5/scripts/env.sh
#python --version 
 
############# CHECKPOINT CONFIGURATION #############
## (Modify as needed)
#if [ $# -gt 2 ]; then
#    BENCHMARK=$1  #select benchmark
#    NUM_CORES=$2 #select number of cores
#    SPEC_VERSION=$3 # select spec version as 2017
#else
#    echo "Your command line contains <2 arguments"
#    exit   
#fi
#
##RUN CONFIG
##CHECKPOINT_CONFIG="multiprogram_4GBmem_50Mn"
##INST_TAKE_CHECKPOINT=50000000
##CHECKPOINT_CONFIG="multiprogram_4GBmem_1281Bn"    # wrf benchmark
##INST_TAKE_CHECKPOINT=1281000000000
#CHECKPOINT_CONFIG="multiprogram_4GBmem_48Bn"    # gcc benchmark

#========================================================================================================

############ CHECKPOINT CONFIGURATION #############
# (Modify as needed)
if [ $# -gt 3 ]; then
    BENCHMARK=$1  #select benchmark
    NUM_CORES=$2 #select number of cores
    SPEC_VERSION=$3 # select spec version as 2017
    NUM=$4 # select the checkpoint number from benchmark.csv
    echo -e "$BENCHMARK"
    echo -e "$NUM_CORES"
    echo -e "$SPEC_VERSION"
    echo -e "$NUM"
    NUM_PART=${NUM:0:4}
    echo -e "$NUM_PART"

else
    echo "Your command line contains <3 arguments"
    exit   
fi
n=3
# RUN CONFIG

# if [ "$NUM_CORES" -eq 1 ]; then                                          #1core
#     CHECKPOINT_CONFIG="multiprogram_4GBmem_${NUM_PART}Mn"
#     #CHECKPOINT_CONFIG="multiprogram_4GBmem_${NUM_PART}Mn_open_policy"
#     #CHECKPOINT_CONFIG="${BENCHMARK}_multiprogram_4GBmem_${NUM_PART}Mn"
#     echo "$CHECKPOINT_CONFIG"
#     INST_TAKE_CHECKPOINT="${NUM_PART}000000"
#     echo "#################### $INST_TAKE_CHECKPOINT"
#     MEM_SIZE="4GB"
# elif [ "$NUM_CORES" -eq 2 ]; then
#     CHECKPOINT_CONFIG="multiprogram_4GBmem_${NUM_PART}Mn"
#     #CHECKPOINT_CONFIG="${BENCHMARK}_multiprogram_4GBmem_${NUM_PART}Mn"
#     echo "$CHECKPOINT_CONFIG"
#     INST_TAKE_CHECKPOINT="${NUM_PART}000000"
#     echo "#################### $INST_TAKE_CHECKPOINT"
#     MEM_SIZE="4GB"
# elif [ "$NUM_CORES" -eq 4 ]; then
#     CHECKPOINT_CONFIG="multiprogram_4GBmem_${NUM_PART}Mn"
#     #CHECKPOINT_CONFIG="${BENCHMARK}_multiprogram_4GBmem_${NUM_PART}Mn"
#     INST_TAKE_CHECKPOINT="${NUM_PART}000000"
#     MEM_SIZE="4GB"
#     echo "$CHECKPOINT_CONFIG"
#     echo "################  $INST_TAKE_CHECKPOINT"
# elif [ "$NUM_CORES" -eq 8 ]; then
#     CHECKPOINT_CONFIG="multiprogram_8GBmem_${NUM_PART}Mn"
#     #CHECKPOINT_CONFIG="${BENCHMARK}_multiprogram_8GBmem_${NUM_PART}Mn"
#     INST_TAKE_CHECKPOINT="${NUM_PART}000000"
#     MEM_SIZE="8GB"
#     echo "$CHECKPOINT_CONFIG"
#     echo "################  $INST_TAKE_CHECKPOINT"
# else
#     CHECKPOINT_CONFIG="multiprogram_16GBmem_${NUM_PART}Mn"
#     INST_TAKE_CHECKPOINT="${NUM_PART}000000"
#     MEM_SIZE="16GB"
# fi



if [ "$NUM_CORES" -eq 1 ]; then                                          #1core
   CHECKPOINT_CONFIG="multiprogram_4GBmem_${NUM_PART}Bn"
   #CHECKPOINT_CONFIG="${BENCHMARK}_multiprogram_4GBmem_${NUM_PART}Mn"
   echo "$CHECKPOINT_CONFIG"
   INST_TAKE_CHECKPOINT="${NUM_PART}000000000"
   echo "#################### $INST_TAKE_CHECKPOINT"
   MEM_SIZE="4GB"
elif [ "$NUM_CORES" -eq 2 ]; then
   CHECKPOINT_CONFIG="multiprogram_4GBmem_${NUM_PART}Bn"
   #CHECKPOINT_CONFIG="${BENCHMARK}_multiprogram_4GBmem_${NUM_PART}Bn"
   echo "$CHECKPOINT_CONFIG"
   INST_TAKE_CHECKPOINT="${NUM_PART}000000000"
   echo "#################### $INST_TAKE_CHECKPOINT"
   MEM_SIZE="4GB"
elif [ "$NUM_CORES" -eq 4 ]; then
   CHECKPOINT_CONFIG="multiprogram_4GBmem_${NUM_PART}Bn"
   #CHECKPOINT_CONFIG="${BENCHMARK}_multiprogram_4GBmem_${NUM_PART}Bn"
   echo "$CHECKPOINT_CONFIG"
   INST_TAKE_CHECKPOINT="${NUM_PART}000000000"
   echo "#################### $INST_TAKE_CHECKPOINT"
   MEM_SIZE="4GB"
elif [ "$NUM_CORES" -eq 8 ]; then
   CHECKPOINT_CONFIG="multiprogram_8GBmem_${NUM_PART}Bn"
   #CHECKPOINT_CONFIG="${BENCHMARK}_multiprogram_8GBmem_${NUM_PART}Bn"
   INST_TAKE_CHECKPOINT="${NUM_PART}000000000"
   echo "$CHECKPOINT_CONFIG"
   echo "################  $INST_TAKE_CHECKPOINT"
   MEM_SIZE="8GB"
else
   CHECKPOINT_CONFIG="multiprogram_16GBmem_${NUM_PART}Bn"
   #CHECKPOINT_CONFIG="${BENCHMARK}_multiprogram_16GBmem_${NUM_PART}Bn"
   INST_TAKE_CHECKPOINT="${NUM}000000000"
   echo "################  $INST_TAKE_CHECKPOINT"
   MEM_SIZE="16GB"
fi


MAX_INSTS=$((INST_TAKE_CHECKPOINT + 1)) #simulate till checkpoint instruction

############ DIRECTORY PATHS TO BE EXPORTED #############

#Need to export GEM5_ROOT
if [ -z ${GEM5_ROOT+x} ];
then
    echo "GEM5_ROOT is unset";
    exit
else
    echo "GEM5_ROOT is set to '$GEM5_ROOT'";
fi
#Need to export SPEC17_ROOT
if [ -z ${SPEC_ROOT+x} ];
then
    echo "SPEC17_ROOT is unset";
    exit
else
    echo "SPEC17_ROOT is set to '$SPEC_ROOT'";
fi
#Need to export CKPT_ROOT
if [ -z ${CKPT_ROOT+x} ];
then
    echo "CKPT_ROOT is unset";
    exit
else
    echo "CKPT_ROOT is set to '$CKPT_ROOT'";
fi


################## DIRECTORY NAMES (CHECKPOINT, OUTPUT, RUN DIRECTORY)  ###################
#Set up based on path variables & configuration

# Ckpt Dir
CKPT_OUT_DIR=$CKPT_ROOT/${CHECKPOINT_CONFIG}.SPEC${SPEC_VERSION}.C${NUM_CORES}/$BENCHMARK-1-ref-x86
echo "checkpoint directory: " $CKPT_OUT_DIR
mkdir -p $CKPT_OUT_DIR

# Output Dir
OUTPUT_DIR=$CKPT_ROOT/output/${CHECKPOINT_CONFIG}.SPEC${SPEC_VERSION}.C${NUM_CORES}/checkpoint_out/$BENCHMARK
echo "output directory: " $OUTPUT_DIR
if [ -d "$OUTPUT_DIR" ]
then
    rm -r $OUTPUT_DIR
fi
mkdir -p $OUTPUT_DIR

# File log used for stdout
SCRIPT_OUT=$OUTPUT_DIR/runscript.log

#Report directory names 
echo "Command line:"                                | tee $SCRIPT_OUT
echo "$0 $*"                                        | tee -a $SCRIPT_OUT
echo "================= Hardcoded directories ==================" | tee -a $SCRIPT_OUT
echo "GEM5_ROOT:                                     $GEM5_ROOT" | tee -a $SCRIPT_OUT
echo "SPEC17_ROOT:                                     $SPEC_ROOT" | tee -a $SCRIPT_OUT
echo "==================== Script inputs =======================" | tee -a $SCRIPT_OUT
echo "BENCHMARK:                                    $BENCHMARK" | tee -a $SCRIPT_OUT
echo "OUTPUT_DIR:                                   $OUTPUT_DIR" | tee -a $SCRIPT_OUT
echo "==========================================================" | tee -a $SCRIPT_OUT
##################################################################


#################### LAUNCH GEM5 SIMULATION ######################
echo ""

echo "" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT
echo "--------- Here goes nothing! Starting gem5! ------------" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT
echo "" | tee -a $SCRIPT_OUT



## Launch Gem5:
#$GEM5_ROOT/build/X86/gem5.opt \
#    --outdir=$OUTPUT_DIR \
#    $GEM5_ROOT/configs/example/se.py \
#    --redirects /lib64=/./lib64 \
#    --benchmark=$BENCHMARK \
#    #--benchmark_stdout=$OUTPUT_DIR/$BENCHMARK.out \
#    #--benchmark_stderr=$OUTPUT_DIR/$BENCHMARK.err \
#    #--spec-version=$SPEC_VERSION \
#    --num-cpus=$NUM_CORES --mem-size=16GB --mem-type=DDR4_2400_16x4 --mem-ranks=1 \
#    --checkpoint-dir=$CKPT_OUT_DIR \
#    --take-checkpoint=$INST_TAKE_CHECKPOINT --at-instruction \
#    --maxinsts=$MAX_INSTS \
#    --prog-interval=300Hz
#    # >> $SCRIPT_OUT 2>&1 &
#
##     --mem-type=SimpleMemory \
#    #--redirects /lib64=/home/utils/gcc-6.2.0/lib64 \
#

#PATH1="/opt/spec2017/benchspec/CPU/gcc/run/run_base_refrate_gem5_se-m64/bin"

#echo "/opt/spec2017/benchspec/CPU/${BENCHMARK}/run/run_base_refrate_gem5_se-m64.0000"
#cd "/opt/spec2017/benchspec/CPU/${BENCHMARK}/run/run_base_refrate_gem5_se-m64.0000"

# #Launch Gem5:         multicore config checkpoint taken from PrIDE
# $GEM5_ROOT/build/X86/gem5.opt \
#     --outdir=$OUTPUT_DIR \
#     $GEM5_ROOT/configs/example/spec17_config_multicore.py \
#     --redirects /lib64=/usr/lib/gcc/x86_64-linux-gnu/5.5.0 \
#     --benchmark=$BENCHMARK \
#     --num-cpus=$NUM_CORES \
#     --mem-type=DRAMSim2 \
#     --caches --l1d_size=32kB --l1i_size=32kB \
#     --l1d_assoc=8 --l1i_assoc=8 \
#     --l2cache --l3cache --sharedl3 \
#     --l2_size=256kB --l2_assoc=16 \
#     --l3_size=1MB --l3_assoc=16 \
#     --cpu-clock=2.4GHz --sys-clock=2.4GHz \
#     --mem-size=$MEM_SIZE --enabledramlog \
#     --dramdeviceconfigfile=$GEM5_ROOT/ext/dramsim2/DRAMSim2/ini/DDR3_micron_32M_8B_x8_sg125.ini \
#     --dramsystemconfigfile=$GEM5_ROOT/ext/dramsim2/DRAMSim2/configs/system_reg_multi.ini \
# 	--checkpoint-dir=$CKPT_OUT_DIR \
#     --take-checkpoint=$INST_TAKE_CHECKPOINT --at-instruction \
#     --maxinsts=$MAX_INSTS \
#     --prog-interval=300Hz \
#     >> $SCRIPT_OUT 2>&1 &

#Launch Gem5:         singlecore config checkpoint
$GEM5_ROOT/build/X86/gem5.opt \
    --outdir=$OUTPUT_DIR \
    $GEM5_ROOT/configs/example/se.py \
    --benchmark=$BENCHMARK \
    --cpu-type=AtomicSimpleCPU \
    --num-cpus=$NUM_CORES \
    --mem-type=DRAMSim2 \
    --caches --l1d_size=32kB --l1i_size=32kB \
    --l1d_assoc=8 --l1i_assoc=8 \
    --l2cache --l3cache \
    --l2_size=256kB --l2_assoc=16 \
    --l3_size=1MB --l3_assoc=16 \
    --cpu-clock=2.4GHz --sys-clock=2.4GHz \
    --mem-size=$MEM_SIZE --enabledramlog \
    --dramdeviceconfigfile=$GEM5_ROOT/ext/dramsim2/DRAMSim2/ini/DDR3_micron_32M_8B_x8_sg125.ini \
    --dramsystemconfigfile=$GEM5_ROOT/ext/dramsim2/DRAMSim2/configs/system_reg_multi.ini \
	--checkpoint-dir=$CKPT_OUT_DIR \
    --take-checkpoint=$INST_TAKE_CHECKPOINT --at-instruction \
    --maxinsts=$MAX_INSTS \
    --prog-interval=300Hz \
    >> $SCRIPT_OUT 2>&1 &

    
#$GEM5_ROOT/configs/example/se.py \

        #--dramsystemconfigfile=$GEM5_ROOT/ext/dramsim2/DRAMSim2/system_reg.ini \  # closed page policy
        #--dramsystemconfigfile=$GEM5_ROOT/ext/dramsim2/DRAMSim2/configs/system_reg_multi.ini \  # open policy

#--cpu-type=DerivO3CPU \
 #       --num-cpus=2 \
#	--benchmark=$SPEC_ROOT/benchspec/CPU/503.bwaves_r/run/run_base_refrate_gem5_se-m64.0000/$BENCHMARK \
	# --benchmark=/opt/spec2017/benchspec/CPU/502.gcc_r/run/run_base_refrate_gem5_se-m64.0000/$BENCHMARK \
# 

## Launch Gem5:
#$GEM5_ROOT/build/X86/gem5.opt \
#    --outdir=$OUTPUT_DIR \
#    $GEM5_ROOT/configs/example/se_rq_spec_config_multicore.py \
#    --redirects /lib64=/./lib64 \
#    --benchmark=$BENCHMARK \
#    --benchmark_stdout=$OUTPUT_DIR/$BENCHMARK.out \
#    --benchmark_stderr=$OUTPUT_DIR/$BENCHMARK.err \
#    --spec-version=$SPEC_VERSION \
#    --num-cpus=$NUM_CORES --mem-size=16GB --mem-type=DDR4_2400_16x4 --mem-ranks=1 \
#    --checkpoint-dir=$CKPT_OUT_DIR \
#    --take-checkpoint=$INST_TAKE_CHECKPOINT --at-instruction \
#    --maxinsts=$MAX_INSTS \
#    --prog-interval=300Hz
#    # >> $SCRIPT_OUT 2>&1 &
#
##     --mem-type=SimpleMemory \
#    #--redirects /lib64=/home/utils/gcc-6.2.0/lib64 \
#
