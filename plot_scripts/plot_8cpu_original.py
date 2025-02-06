import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import sys
import os
import csv
import re
from scipy import stats

gem5root = os.environ.get('GEM5_ROOT')
specroot = os.environ.get('SPEC_ROOT') 

assert(gem5root is not None)
assert(specroot is not None)

# Modified DataFrame to include 8 CPU cores
df = pd.DataFrame(columns=["test", "chkptnum", "trial"] + [f"cpu{i}_ipc" for i in range(8)] + ["ticks"])

# exprs = ['blender_r', 'cactuBSSN_r', 'deepsjeng_r', 'exchange2_r', 'fotonik3d_r', 
#          'lbm_r', 'leela_r', 'nab_r', 'namd_r', 'povray_r', 'roms_r', 'wrf_r', 
#          'x264_r', 'xz_r']

exprs = ['xz_r']

if len(sys.argv) <= 2:
    print("Usage: plot_8cpu.py results_dir testname1 testname2 testname3")
    print("Example: plot_8cpu.py $GEM5_ROOT/eval_scripts/simu_condor/results/ docDist_8cpu_DAGguise docDist_8cpu_FSBTA docDist_8cpu_regular")
    exit(0)

resultsdir = sys.argv[1]

for trialName in sys.argv[2:]:
    for testName in next(os.walk(os.path.join(sys.argv[1], trialName)))[1]:
        if testName not in exprs: 
            continue

        for checkpointNum in next(os.walk(os.path.join(resultsdir, trialName, testName)))[1]:
            procDict = {
                "test": testName[:-2],
                "trial": "DAGguise" if "DAGguise" in trialName else "FS-BTA" if "FSBTA" in trialName else trialName,
                "chkptnum": checkpointNum
            }

            with open(os.path.join(resultsdir, trialName, testName, 'stats.txt')) as f:
                for line in f.readlines():
                    if "system.switch_cpus_10.ipc" in line:
                        procDict["cpu0_ipc"] = float(re.split(r'[ ]+',line)[1])
                    if "system.switch_cpus_11.ipc" in line:
                        procDict["cpu1_ipc"] = float(re.split(r'[ ]+',line)[1])
                    if "system.switch_cpus_12.ipc" in line:
                        procDict["cpu2_ipc"] = float(re.split(r'[ ]+',line)[1])
                    if "system.switch_cpus_13.ipc" in line:
                        procDict["cpu3_ipc"] = float(re.split(r'[ ]+',line)[1])
                    if "system.switch_cpus_14.ipc" in line:
                        procDict["cpu4_ipc"] = float(re.split(r'[ ]+',line)[1])
                    if "system.switch_cpus_15.ipc" in line:
                        procDict["cpu5_ipc"] = float(re.split(r'[ ]+',line)[1])
                    if "system.switch_cpus_16.ipc" in line:
                        procDict["cpu6_ipc"] = float(re.split(r'[ ]+',line)[1])
                    if "system.switch_cpus_17.ipc" in line:
                        procDict["cpu7_ipc"] = float(re.split(r'[ ]+',line)[1])
                    elif "sim_ticks" in line:
                        procDict["ticks"] = int(re.split(r'[ ]+',line)[1])
                    # Modified to handle 8 CPUs
                    # for i in range(8):
                    #     if f"system.switch_cpus_{i*2}.ipc" in line:
                    #         procDict[f"cpu{i}_ipc"] = float(re.split(r'[ ]+',line)[1])
                    # if "sim_ticks" in line:
                    #     procDict["ticks"] = int(re.split(r'[ ]+',line)[1])
            
            df = df.append(procDict, ignore_index=True)

pd.set_option("display.max_rows", None, "display.max_columns", None)

# Drop failed tests
failed = df[df.isna().any(axis=1)]
for index, row in failed.iterrows():
    print(f"Dropping {row['test']}, {row['chkptnum']}")
    df = df.drop(df[(df['test'] == row['test']) & (df['chkptnum'] == row['chkptnum'])].index)

g = df.groupby(['test','trial'], as_index=False)

# Calculate weighted IPC for all 8 cores
for i in range(8):
    df[f'cpu_{i}_ipc_wa'] = df[f'cpu{i}_ipc'] * 100

# Calculate IPC sums for different process types
ipc_lists = []
for i in range(8):
    ipc_lists.append(g[f'cpu_{i}_ipc_wa'].sum())

def divide_by(g, name, denom_lvl):
    cols = [name]
    num = g[cols]
    denom = g.loc[g.trial==denom_lvl, cols].iloc[0]
    return num.divide(denom*8)  # Modified to divide by 8 cores

# Calculate normalized values for different process types
process_types = ['SPEC', 'DocDist', 'DNA']
ipc_normalized = pd.DataFrame()
for i, ipc in enumerate(ipc_lists):
    if i < 4:
        process_type = 'SPEC'
    elif i < 6:
        process_type = 'DocDist'
    else:
        process_type = 'DNA'
    
    ipc[process_type] = ipc.groupby(['test']).apply(
        divide_by, 
        name=f'cpu_{i}_ipc_wa', 
        denom_lvl='docDist_8cpu_regular'
    )

def plot_clustered_stacked(dfall, labels=None, title="multiple stacked bar plot", H="/", **kwargs):
    n_df = len(dfall)
    n_col = len(dfall[0].columns)
    n_ind = len(dfall[0].index)
    axe = plt.subplot(111)
    colors = ['gainsboro', 'dimgray']

    for i, df in enumerate(dfall):
        axe = df.plot(kind="bar",
                     linewidth=1,
                     stacked=True,
                     ax=axe,
                     legend=False,
                     grid=False,
                     edgecolor='black',
                     color='white',
                     **kwargs)

    h, l = axe.get_legend_handles_labels()
    for i in range(0, n_df * n_col, n_col):
        for j, pa in enumerate(h[i:i+n_col]):
            for rect in pa.patches:
                rect.set_x(rect.get_x() + 1 / float(n_df + 1) * i / float(n_col) - 0.125)
                rect.set_hatch(H * int(j)*2)
                rect.set_width(1 / float(n_df + 1))
                rect.set_facecolor(colors[int(i / (n_col))])

    axe.set_xticks((np.arange(0, 2 * n_ind, 2) - 0.35 + 1 / float(n_df + 1)) / 2.)
    axe.set_xticklabels(df.index, rotation=30, ha="right")
    axe.set_yticks(np.arange(0.0, 1.1, 0.1))
    axe.set_yticklabels([f"{y:.1f}" for y in np.arange(0.0, 1.1, 0.1)])
    axe.set_ylabel("Average Normalized IPC")

    # Legend
    n = [axe.bar(0, 0, color=colors[i], edgecolor='black') for i in range(n_df)]
    l1 = axe.legend(n, labels, loc='upper center', bbox_to_anchor=(0.225, 1.19), 
                    ncol=2, columnspacing=0.3, handletextpad=0.2)
    
    if labels is not None:
        l2 = plt.legend(h[:n_col], l[:n_col], loc='upper center', 
                       bbox_to_anchor=(0.8, 1.19), ncol=3, columnspacing=0.3, 
                       handletextpad=0.2)
        l2.legendHandles[0].set_facecolor('white')
        l2.legendHandles[1].set_facecolor('white')
        l2.legendHandles[2].set_facecolor('white')
    axe.add_artist(l1)
    return axe

# Prepare data for plotting
df_list = []
trial_list = []
for trialRow in sorted(df.trial.unique(), reverse=True):
    if "regular" in trialRow:
        continue
        
    geodict = {
        "test": "geomean",
        "DocDist": stats.gmean(ipc[ipc['trial'] == trialRow][['DocDist']])[0].astype(float),
        "DNA": stats.gmean(ipc[ipc['trial'] == trialRow][['DNA']])[0].astype(float),
        "SPEC": stats.gmean(ipc[ipc['trial'] == trialRow][['SPEC']])[0].astype(float)
    }
    
    df_list.append(ipc[ipc['trial'] == trialRow][['test', 'DocDist', 'DNA', 'SPEC']]
                  .append(geodict, ignore_index=True).set_index('test'))
    trial_list.append(trialRow)

# Plot configuration and generation
plt.rcParams["figure.figsize"] = (6, 2.75)
plot_clustered_stacked(df_list, trial_list, title="Average Normalized Speedup")

box = plt.axes().get_position()
plt.axes().set_position([box.x0, box.y0+0.125, box.width*1.1, box.height*0.85])

plt.savefig("8cpu_recent.pdf")
plt.show()