#!/usr/bin/env python

import sys

infile=sys.argv[1]

RESULTS = {}

with open(infile, 'r') as f:
  for line in f.readlines()[1:]:
    LIS_line = line.rstrip().split('\t')
    genes, probands, controls = (LIS_line[25], LIS_line[51], LIS_line[52])
    LIS_genes = genes.split('|')
    LIS_probands = probands.split(',')
    LIS_controls = controls.split(',')
    LIS_samples = LIS_probands + LIS_controls
    for gene in LIS_genes:
      if gene not in RESULTS: RESULTS[gene]={}
      for sample in LIS_samples:
        if sample == "": continue
        if sample not in RESULTS[gene]: RESULTS[gene][sample] = 0
        RESULTS[gene][sample]+=1

for gene in RESULTS:
  LIS_compoundHits = [sample for sample in RESULTS[gene] if RESULTS[gene][sample]>1]
  if len(LIS_compoundHits)==0: continue
  STR_samples = ','.join(LIS_compoundHits)
  print ('\t'.join([gene, STR_samples]))
