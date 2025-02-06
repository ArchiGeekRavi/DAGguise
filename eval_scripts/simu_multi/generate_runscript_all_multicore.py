import os
import sys
import subprocess
from shutil import copyfile

# Environment variables
gem5root = os.environ.get('GEM5_ROOT')
specroot = os.environ.get('SPEC_ROOT')

assert gem5root is not None, "GEM5_ROOT is not set!"
assert specroot is not None, "SPEC_ROOT is not set!"

# Check if enough arguments are passed
assert len(sys.argv) > 2, "Usage: python3 generate_runscript_all.py <template_script> <benchmark_name>"

# Arguments
template_script = sys.argv[1]         # Template script
benchmark_name = sys.argv[2]          # Benchmark name

# Extract the name (e.g., "docDist_2cpu_DAGguise") from the template_script
template_name = os.path.basename(template_script).replace(".sh", "")  # Get base name and remove ".sh"

# Paths
# ckptdir = os.path.join(gem5root, f"checkpoint_merge_multicore_xz_single_dna/merged_checkpoint_{benchmark_name}")
ckptdir = os.path.join(gem5root, f"checkpoint_merge_multicore/merged_checkpoint_{benchmark_name}")
# ckptdir = os.path.join(gem5root, f"checkpoint_merge_singlecore_xz/merged_checkpoint_{benchmark_name}")
resultsdir_base = os.path.join(gem5root, f"eval_scripts/simu_simple_multi/results/{template_name}")
resultsdir = os.path.join(resultsdir_base, benchmark_name)  # Result directory for this benchmark
os.makedirs(resultsdir, exist_ok=True)

# Define the output log file
script_out = os.path.join(resultsdir, "runscript.log")

# Script setup
runscriptFile = 'runscript_multicore.sh'

# Copy the template script
copyfile(template_script, runscriptFile)

# Add checkpoint-specific arguments to the script
with open(runscriptFile, "a+") as runHandle:
    runHandle.write(f'\t--benchmark={benchmark_name} \\\n')
    runHandle.write(f'\t--checkpoint-dir={ckptdir} \\\n')
    runHandle.write(f'\t--simpt-ckpt=0 \\\n')  # Default checkpoint number is 0
    runHandle.write(f'\t--dramsim2outputfile={resultsdir}/dram \\\n')
    runHandle.write(f'\t> {script_out} 2>&1 \\\n')


# Replace placeholder in the template and make the script executable
subprocess.call(["sed", "-i", "-e", f's|OUTDIR_REPLACE|{resultsdir}|g', runscriptFile])
subprocess.call(["chmod", "+x", runscriptFile])
