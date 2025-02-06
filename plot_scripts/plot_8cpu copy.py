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

exprs = ['blender_r', 'cactuBSSN_r', 'deepsjeng_r', 'exchange2_r', 'fotonik3d_r', 'lbm_r', 'leela_r', 'nab_r', 'namd_r', 'povray_r', 'roms_r', 'wrf_r', 'x264_r', 'xz_r']



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
            
            df = df.append(procDict, ignore_index=True)

pd.set_option("display.max_rows", None, "display.max_columns", None)
print(df)

print("=== IPC Stats ===\n")

# Drop failed tests
failed = df[df.isna().any(axis=1)]
for index, row in failed.iterrows():
    print(f"Dropping {row['test']}, {row['chkptnum']}")
    df = df.drop(df[(df['test'] == row['test']) & (df['chkptnum'] == row['chkptnum'])].index)

# g = df.groupby(['test','trial'], as_index=False)

# df['cpu_0_ipc_wa'] = df.cpu0_ipc * 100
# df['cpu_1_ipc_wa'] = df.cpu1_ipc * 100
# df['cpu_2_ipc_wa'] = df.cpu2_ipc * 100
# df['cpu_3_ipc_wa'] = df.cpu3_ipc * 100
# df['cpu_4_ipc_wa'] = df.cpu4_ipc * 100
# df['cpu_5_ipc_wa'] = df.cpu5_ipc * 100
# df['cpu_6_ipc_wa'] = df.cpu6_ipc * 100
# df['cpu_7_ipc_wa'] = df.cpu7_ipc * 100

# ipc_0 = g.cpu_0_ipc_wa.sum()
# ipc_1 = g.cpu_1_ipc_wa.sum()
# ipc_2 = g.cpu_2_ipc_wa.sum()
# ipc_3 = g.cpu_3_ipc_wa.sum()
# ipc_4 = g.cpu_4_ipc_wa.sum()
# ipc_5 = g.cpu_5_ipc_wa.sum()
# ipc_6 = g.cpu_6_ipc_wa.sum()
# ipc_7 = g.cpu_7_ipc_wa.sum()

# Calculate weighted IPC for all 8 cores
for i in range(8):
    df[f'cpu_{i}_ipc_wa'] = df[f'cpu{i}_ipc'] * 100

# def calculate_normalized_ipc(group, baseline_group):
#     # Calculate normalized IPC for each core type
#     spec_cores = sum(group[f'cpu_{i}_ipc_wa'] for i in range(4))
#     print("spec_cores", spec_cores)
#     docdist_cores = sum(group[f'cpu_{i}_ipc_wa'] for i in range(4, 6))
#     print(docdist_cores)
#     dna_cores = sum(group[f'cpu_{i}_ipc_wa'] for i in range(6, 8))
#     print(dna_cores)
    
#     baseline_total = sum(baseline_group[f'cpu_{i}_ipc_wa'] for i in range(8))
    
#     return pd.Series({
#         'SPEC': spec_cores / (baseline_total),
#         'DocDist': docdist_cores / (baseline_total),
#         'DNA': dna_cores / (baseline_total)
#     })

def calculate_normalized_ipc(group, baseline_group):
    spec_cores = sum(group[f'cpu_{i}_ipc_wa'] for i in range(4)) / sum(baseline_group[f'cpu_{i}_ipc_wa'] for i in range(4)) / 3
    docdist_cores = sum(group[f'cpu_{i}_ipc_wa'] for i in range(4, 6)) / sum(baseline_group[f'cpu_{i}_ipc_wa'] for i in range(4, 6)) / 3
    dna_cores = sum(group[f'cpu_{i}_ipc_wa'] for i in range(6, 8)) / sum(baseline_group[f'cpu_{i}_ipc_wa'] for i in range(6, 8)) / 3
    
    return pd.Series({'SPEC': spec_cores, 'DocDist': docdist_cores, 'DNA': dna_cores})

# Initialize the result DataFrame
result_df = pd.DataFrame()

# Process each test and trial
for test in df['test'].unique():
    test_data = df[df['test'] == test]
    baseline_data = test_data[test_data['trial'].str.contains('regular')].iloc[0]
    
    for trial in test_data['trial'].unique():
        if 'regular' in trial:
            continue
            
        trial_data = test_data[test_data['trial'] == trial].iloc[0]
        normalized_values = calculate_normalized_ipc(trial_data, baseline_data)
        
        result_row = pd.DataFrame({
            'test': [test],
            'trial': [trial],
            'SPEC': [normalized_values['SPEC']],
            'DocDist': [normalized_values['DocDist']],
            'DNA': [normalized_values['DNA']]
        })
        
        result_df = pd.concat([result_df, result_row])

# Calculate geometric mean
for trial in result_df['trial'].unique():
    geo_means = {
        'SPEC': stats.gmean(result_df[result_df['trial'] == trial]['SPEC']),
        'DocDist': stats.gmean(result_df[result_df['trial'] == trial]['DocDist']),
        'DNA': stats.gmean(result_df[result_df['trial'] == trial]['DNA'])
    }
    
    geo_row = pd.DataFrame({
        'test': ['geomean'],
        'trial': [trial],
        'SPEC': [geo_means['SPEC']],
        'DocDist': [geo_means['DocDist']],
        'DNA': [geo_means['DNA']]
    })
    
    result_df = pd.concat([result_df, geo_row])

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
        for handle in l2.legendHandles:
            handle.set_facecolor('white')
    axe.add_artist(l1)
    return axe

# Prepare data for plotting
df_list = []
trial_list = []
for trial in sorted(result_df['trial'].unique(), reverse=True):
    trial_data = result_df[result_df['trial'] == trial].set_index('test')[['DocDist', 'DNA', 'SPEC']]
    df_list.append(trial_data)
    trial_list.append(trial)

# Plot configuration and generation
plt.rcParams["figure.figsize"] = (6, 2.75)
plot_clustered_stacked(df_list, trial_list, title="Average Normalized Speedup")

box = plt.axes().get_position()
plt.axes().set_position([box.x0, box.y0+0.125, box.width*1.1, box.height*0.85])

plt.savefig("8cpu_recent.pdf")
plt.show()
