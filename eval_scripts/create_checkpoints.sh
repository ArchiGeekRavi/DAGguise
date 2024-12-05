#!/bin/bash

######----------------------------------------------------- ######
######------------- CHECKPOINTS FOR 4/1-CORE EXPERIMENTS -- ######
######----------------------------------------------------- ######

## Set the paths
#source env.sh;

############ FUNCTION TO GET NUM VALUE #############
get_num_value() {
    local benchmark=$1
    local num_value=""

    while IFS='|' read -r name num; do
        if [ "$name" == "$benchmark" ]; then
            num_value=$num
            break
        fi
    done < benchmarks.csv

    echo "$num_value"
}

## Error Checking
if [ -z ${MAX_GEM5_PARALLEL_RUNS+x} ]; then
    echo "MAX_GEM5_PARALLEL_RUNS is unset";
    exit
else
    echo "MAX_GEM5_PARALLEL_RUNS is set to '$MAX_GEM5_PARALLEL_RUNS'";
fi

qsub=$1
# Check if $qsub is empty
if [ -z "$qsub" ]; then
    qsub=0
fi
if [ $qsub -gt 0 ]; then
    qsub=1
    qsub_cmdfile="run_cmds.txt"
    rm -rf $qsub_cmdfile
    touch $qsub_cmdfile
fi

# Function to wait for available core
wait_for_available_core() {
    while [ $(ps aux | grep -i "gem5" | grep -i "dag" | grep -v "grep" | wc -l) -gt ${MAX_GEM5_PARALLEL_RUNS} ]; do
        sleep 300
    done
}

echo "Creating 1-Core Checkpoints for 15 Benchmarks"                               # 1core
#for bmk in namd_r leela_r exchange2_r xz_r x264_r fotonik3d_r; do
#for bmk in perlbench_r gcc_r bwaves_r mcf_r cactuBSSN_r namd_r povray_r lbm_r wrf_r\
#   blender_r deepsjeng_r imagick_r leela_r nab_r exchange2_r roms_r xz_r parest_r; do
#for bmk in cam4_r fotonik3d_r x264_r cactuBSSN_r namd_r povray_r lbm_r wrf_r\
#   blender_r deepsjeng_r leela_r nab_r exchange2_r roms_r xz_r; do
for bmk in blender_r cactuBSSN_r deepsjeng_r exchange2_r fotonik3d_r lbm_r leela_r nab_r namd_r povray_r roms_r wrf_r x264_r xz_r; do
   NUM=$(grep "$bmk" benchmarks.csv | cut -d "," -f 2 | tr -d '\r')
   if [ -z "$NUM" ]; then
       echo "No checkpoint number found for benchmark $bmk in benchmarks.csv"
       continue
   fi

   if [ $qsub -gt 0 ]; then
	echo "enter in qsub 1"    
       #echo "./ckptscript.sh $bmk 1 2017 $NUM" >> $qsub_cmdfile
       echo "./ckptscript.sh $bmk 1 2017 25" >> $qsub_cmdfile
       #echo "./ckptscript.sh $bmk 1 2017 50" >> $qsub_cmdfile
   else
	echo "enter to wait for available core 1"
       wait_for_available_core
       #./ckptscript.sh $bmk 1 2017 $NUM &
      # ./ckptscript.sh $bmk 1 2017 50 &               # 50Mn
      ./ckptscript.sh $bmk 1 2017 25 &               # 25Bn
       #./ckptscript.sh $bmk 2 2017 1 &               # 1Mn
   fi
done


#echo "Creating 2-Core Checkpoints for 15 Benchmarks"
#for bmk in namd_r leela_r exchange2_r xz_r x264_r fotonik3d_r; do
##for bmk in perlbench_r gcc_r bwaves_r mcf_r cactuBSSN_r namd_r povray_r lbm_r wrf_r\
##   blender_r deepsjeng_r imagick_r leela_r nab_r exchange2_r roms_r xz_r parest_r; do
#    NUM=$(grep "$bmk" benchmarks.csv | cut -d "," -f 2 | tr -d '\r')
#    if [ -z "$NUM" ]; then
#        echo "No checkpoint number found for benchmark $bmk in benchmarks.csv"
#        continue
#    fi
#
#    if [ $qsub -gt 0 ]; then
#	echo "enter in qsub 2"    
#        #echo "./ckptscript.sh $bmk 2 2017 $NUM" >> $qsub_cmdfile
#        #echo "./ckptscript.sh $bmk 2 2017 25" >> $qsub_cmdfile
#        echo "./ckptscript.sh $bmk 2 2017 1" >> $qsub_cmdfile
#    else
#	echo "enter to wait for available core 2"
#        wait_for_available_core
#        #./ckptscript.sh $bmk 2 2017 $NUM &
#        ./ckptscript.sh $bmk 2 2017 25 &               # 50Mn
#        #./ckptscript.sh $bmk 2 2017 1 &               # 50Mn
#    fi
#done
#
# echo "Creating 4-Core Checkpoints for 15 Benchmarks"
# #for bmk in namd_r leela_r exchange2_r xz_r x264_r fotonik3d_r; do
# #for bmk in perlbench_r gcc_r bwaves_r mcf_r cactuBSSN_r namd_r povray_r lbm_r wrf_r\
# #   blender_r deepsjeng_r imagick_r leela_r nab_r exchange2_r roms_r xz_r parest_r; do
# #for bmk in exchange2_r; do
# for bmk in exchange2; do
#     NUM=$(grep "$bmk" benchmarks.csv | cut -d "," -f 2 | tr -d '\r')
#     if [ -z "$NUM" ]; then
#         echo "No checkpoint number found for benchmark $bmk in benchmarks.csv"
#         continue
#     fi

#     if [ $qsub -gt 0 ]; then
# 	echo "enter in qsub 4"    
#         #echo "./ckptscript.sh $bmk 4 2017 $NUM" >> $qsub_cmdfile
#         #echo "./ckptscript.sh $bmk 4 2017 25" >> $qsub_cmdfile
#         echo "./ckptscript.sh $bmk 4 2017 10" >> $qsub_cmdfile
#         #echo "./ckptscript.sh $bmk 4 2017 1" >> $qsub_cmdfile
#     else
# 	echo "enter to wait for available core 4"
#         wait_for_available_core
#         #./ckptscript.sh $bmk 4 2017 $NUM &
#         #./ckptscript.sh $bmk 4 2017 25 &               # 25Bn
#         #./ckptscript.sh $bmk 4 2017 50 &               # 50Mn
#         ./ckptscript.sh $bmk 4 2017 10 &               # 10Mn
#     fi
# done

#
#echo "Creating 8-Core Checkpoints for 15 Benchmarks"
#for bmk in namd_r leela_r exchange2_r xz_r x264_r fotonik3d_r; do
##for bmk in perlbench_r gcc_r bwaves_r mcf_r cactuBSSN_r namd_r povray_r lbm_r wrf_r\
##   blender_r deepsjeng_r imagick_r leela_r nab_r exchange2_r roms_r xz_r parest_r; do
#    NUM=$(grep "$bmk" benchmarks.csv | cut -d "," -f 2 | tr -d '\r')
#    if [ -z "$NUM" ]; then
#        echo "No checkpoint number found for benchmark $bmk in benchmarks.csv"
#        continue
#    fi
#
#    if [ $qsub -gt 0 ]; then
#	echo "enter in qsub 8"    
#        #echo "./ckptscript.sh $bmk 8 2017 $NUM" >> $qsub_cmdfile
#        #echo "./ckptscript.sh $bmk 8 2017 25" >> $qsub_cmdfile
#        echo "./ckptscript.sh $bmk 8 2017 1" >> $qsub_cmdfile
#    else
#	echo "enter to wait for available core 8"
#        wait_for_available_core
#        #./ckptscript.sh $bmk 8 2017 $NUM &
#        ./ckptscript.sh $bmk 8 2017 25 &                    # 50Mn
#        #./ckptscript.sh $bmk 8 2017 1 &                    # 50Mn
#    fi
#done
#
#echo "Creating 16-Core Checkpoints for 15 Benchmarks"
#for bmk in namd_r leela_r exchange2_r xz_r x264_r fotonik3d_r; do
##for bmk in perlbench_r gcc_r bwaves_r mcf_r cactuBSSN_r namd_r povray_r lbm_r wrf_r\
##   blender_r deepsjeng_r imagick_r leela_r nab_r exchange2_r roms_r xz_r parest_r; do
#    NUM=$(grep "$bmk" benchmarks.csv | cut -d "," -f 2 | tr -d '\r')
#    if [ -z "$NUM" ]; then
#        echo "No checkpoint number found for benchmark $bmk in benchmarks.csv"
#        continue
#    fi
#
#    if [ $qsub -gt 0 ]; then
#	echo "enter in qsub 16"    
#        #echo "./ckptscript.sh $bmk 16 2017 $NUM" >> $qsub_cmdfile
#        #echo "./ckptscript.sh $bmk 16 2017 25" >> $qsub_cmdfile
#        echo "./ckptscript.sh $bmk 16 2017 1" >> $qsub_cmdfile
#    else
#	echo "enter to wait for available core 16"
#        wait_for_available_core
#        #./ckptscript.sh $bmk 16 2017 $NUM &
#        ./ckptscript.sh $bmk 16 2017 25 &                    # 50Mn
#        #./ckptscript.sh $bmk 16 2017 1 &                    # 50Mn
#    fi
#done


wait

if [ $qsub -gt 0 ]; then
    echo "Sending jobs to farm"

    # Inline run_qsub.sh logic
    if [ ! -f "$qsub_cmdfile" ]; then
        echo "Command file $qsub_cmdfile does not exist!"
        exit 1
    fi

    while IFS= read -r cmd; do
        qsub -b y -cwd -V -N jobname "$cmd"
    done < "$qsub_cmdfile"

    echo "Done sending jobs to farm"
else
    # Wait for all checkpoints to be created before exiting
    while [ $(ps aux | grep -i "gem5" | grep -i "dag" | grep -v "grep" | wc -l) -gt 0 ]; do
        sleep 300
        echo "Still running $(ps aux | grep -i "gem5" | grep -i "dag" | grep -v "grep" | wc -l) gem5 checkpointing processes"
    done
fi

