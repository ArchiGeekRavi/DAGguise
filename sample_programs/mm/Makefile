# Targets
all: mm_checkpoint

# Target to build with DUMP_CHECKPOINT
mm_checkpoint: mm.cpp zsim_hooks.h
	g++ -std=c++11 -static mm.cpp -o mm_checkpoint -DDUMP_CHECKPOINT

# Clean up the build artifacts
clean:
	rm -f mm_checkpoint

# Phony targets
.PHONY: all clean
