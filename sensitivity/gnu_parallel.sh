#!/bin/bash

# Ensure GEM5_ROOT environment variable is set
if [ -z "$GEM5_ROOT" ]; then
  echo "GEM5_ROOT is not set. Please set it before running the script."
  exit 1
fi

# Define the log directory
LOG_DIR="sensitivity_logs"
mkdir -p $LOG_DIR

# Find all the runscript.sh files inside the GEM5_ROOT/sensitivity/*/ directory
find /home/user/DAGguise/sensitivity/*/*_runscript.sh > file_list.txt

# Run jobs in parallel using GNU Parallel
cat file_list.txt | parallel -j 30 --env GEM5_ROOT --workdir $PWD \
    'echo "Running {}"; \
    source {} > $LOG_DIR/$(basename {} .sh).out 2> $LOG_DIR/$(basename {} .sh).error; \
    echo "Finished {}"'

echo "All jobs completed."
