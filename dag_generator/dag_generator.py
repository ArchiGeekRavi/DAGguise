#!/usr/bin/env python

import sys, argparse, json

# Gather our code in a main() function
def main(args):
  # Extract arguments
  numPhase = args.numphase   # 100
  numPara = args.para        # 8
  wbRatio = args.wbratio     # 11
  latency = args.weight      # 100
  numBanks = args.numbanks   # 8

  print(f"numPhase: {numPhase}, numPara: {numPara}, wbRatio: {wbRatio}, latency: {latency}, numBanks: {numBanks}")

  node = []
  edge = []

  # Start node
  node.append({"nodeID": 0, "bankID": 0, "combinedWB": 1, "combinedWBBankID": 0})
  print(f"Start node: {node[-1]}")

  # Main nodes
  for phaseID in range(numPhase):
    for paraID in range(numPara):
      nodeID = phaseID * numPara + paraID + 1
      combinedWB = int(phaseID % wbRatio == 0)
      bankID = nodeID % numBanks
      node.append({"nodeID": nodeID, "bankID": bankID, "combinedWB": combinedWB, "combinedWBBankID": bankID})
      print(f"Main node: {node[-1]} (Phase: {phaseID}, Para: {paraID})")

  # End node
  endNode = {"nodeID": numPhase * numPara + 1, "bankID": 0, "combinedWB": 1, "combinedWBBankID": 0}
  node.append(endNode)
  print(f"End node: {endNode}")

  # Start edges
  for paraID in range(numPara):
    edge.append({"sourceID": 0, "destID": paraID + 1, "latency": latency})
    print(f"Start edge: {edge[-1]}")

  # Main edges
  for phaseID in range(numPhase - 1):
    for paraID in range(numPara):
      nodeID0 = phaseID * numPara + paraID + 1
      nodeID1 = (phaseID + 1) * numPara + paraID + 1
      edge.append({"sourceID": nodeID0, "destID": nodeID1, "latency": latency})
      print(f"Main edge: {edge[-1]} (Phase: {phaseID}, Para: {paraID})")

  # End edges
  for paraID in range(numPara):
    edge.append({"sourceID": numPhase * numPara - paraID, "destID": numPhase * numPara + 1, "latency": latency})
    print(f"End edge: {edge[-1]}")

  # Create final JSON structure
  finalJson = {"0": {"loop": 100, "node": node, "edge": edge}}
  print(f"Final DAG structure:\n{json.dumps(finalJson, indent=2)}")

  # Write the result to the output file
  with open(args.outputfile, 'w') as json_file:
    json.dump(finalJson, json_file, indent=4)
  print(f"DAG saved to {args.outputfile}")

if __name__ == '__main__':
  parser = argparse.ArgumentParser(description="Generates defense rDAGs according to the template shown in Figure 6")
  
  parser.add_argument("--para", type=int, default=8, help="rDAG Parallelism")
  parser.add_argument("--weight", type=int, default=100, help="Edge Weight")
  parser.add_argument("--wbratio", type=int, default=11, help="How many phases should we go before writing?")
  parser.add_argument("--numphase", type=int, default=100, help="Number of Phases")
  parser.add_argument("--numbanks", type=int, default=8, help="Number of DRAM Banks")
  parser.add_argument("--outputfile", type=str, default="defense.json", help="DAG output file name")

  args = parser.parse_args()
  
  main(args)
