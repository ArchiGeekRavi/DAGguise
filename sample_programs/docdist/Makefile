all: docDist docDist_checkpoint
docDist_checkpoint: docDist.cpp zsim_hooks.h
	g++ -std=c++11 -static docDist.cpp -o docDist_checkpoint -DDUMP_CHECKPOINT  # @Ravi: added "-std=c++11"
docDist: docDist.cpp zsim_hooks.h
	g++ -std=c++11 -static docDist.cpp -o docDist  # @Ravi: added "-std=c++11"

