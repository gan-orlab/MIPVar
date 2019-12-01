#!/usr/bin/env python

import sys
import re

# parse input args
covar=sys.argv[1]
infile=sys.argv[2]
cutoff=float(sys.argv[3])

# object to store sample and cohort information (to be used for cohort-specific AF filtering
SAMPLE2COHORT = {}
# object to store all HETEROZYGOUS variants, keyed by gene (primary) and sample (secondary)
DATA = {}
# object to store the subset of DATA that are compound hets, on a gene-by-gene basis
COMPOUND_HETS = {}

# read through covar file to link sample and cohort information
with open(covar, 'r') as f:
  for line in f.readlines():
    LIS_line = line.rstrip().split('\t')
    sample, cohort = (LIS_line[0], LIS_line[5])
    # convert numerically coded cohorts to human-readable strings
    cohort = 'NFE' if cohort=='1' else 'ASJ'
    SAMPLE2COHORT.update({sample:cohort})

# read through data file and parse all the data
f = open(infile, 'r')
for i,line in enumerate(f):
  LIS_line = line.rstrip().split('\t')
  # use header line to identify column numbers for various useful data points to be used in future parsing
  if i==0:
    chr_col  = LIS_line.index('Chr')
    pos_col  = LIS_line.index('Position')
    REF_col  = LIS_line.index('Reference Allele')
    ALT_col  = LIS_line.index('Mutant Allele')
    gene_col = LIS_line.index('"Gene symbol" (Gene)')
    probWvarList_col = LIS_line.index('Probands w/ variant individual names')
    ctrlWvarList_col = LIS_line.index('Familial controls w/ variant individual names')
    familyMembersList_col = LIS_line.index('Family members')
    firstZygosity_col = LIS_line.index('Family member zygosity')
    ASJExomeFreq_col  = LIS_line.index('"gnomAD ASJ exome allele frequency (version Annovar - 20170311)" (gnomAD_exome_ASJ)')
    NFEExomeFreq_col  = LIS_line.index('"gnomAD NFE exome allele frequency (version Annovar - 20170311)" (gnomAD_exome_NFE)')
    ASJGenomeFreq_col = LIS_line.index('"gnomAD ASJ genome allele frequency (version Annovar - 20170311)" (gnomAD_genome_ASJ)')
    NFEGenomeFreq_col = LIS_line.index('"gnomAD NFE genome allele frequency (version Annovar - 20170311)" (gnomAD_genome_NFE)')
    continue
  # read the rest of the file and parse the data   
  # at 1st data line (2nd line), create dict linking sample names to zygosity columns (only need to do this once if there is only 1 "family" in segregation results
  if i==1:
    LIS_familyMembers     = LIS_line[familyMembersList_col].split(',')
    LIS_familyMembersCols = [firstZygosity_col+(6*i) for i in range(0,len(LIS_familyMembers))]
    DIC_sample2col = dict(zip(LIS_familyMembers, LIS_familyMembersCols))
  # parse useful variables from data: variant, genes, lists; cohort-specific gnomad frequencies
  variant = ':'.join([LIS_line[i] for i in [chr_col, pos_col, REF_col, ALT_col]])
  genes, probandsWvar, controlsWvar = [LIS_line[i] for i in [gene_col, probWvarList_col, ctrlWvarList_col]]
  ASJExomeFreq, ASJGenomeFreq, NFEExomeFreq, NFEGenomeFreq = [float(LIS_line[i]) if LIS_line[i] else float(0) for i in [ASJExomeFreq_col, ASJGenomeFreq_col, NFEExomeFreq_col, NFEGenomeFreq_col]]
  # set gnomad AF filtering flags, and skip current variant if all frequencies exceed cutoff value
  ASJrare = ASJExomeFreq <= cutoff and ASJGenomeFreq <= cutoff
  NFErare = NFEExomeFreq <= cutoff and NFEGenomeFreq <= cutoff
  Cohort2Filter = {'ASJ':ASJrare, 'NFE':NFErare}
  if not ASJrare and not NFErare: continue
  # parse lists from potentially multi-value columns
  LIS_genes = genes.split('|')
  LIS_probands = probandsWvar.split(',')
  LIS_controls = controlsWvar.split(',')
  LIS_samples = LIS_probands + LIS_controls
  # add gene, sample, variant info to data object for later calculations
  for gene in LIS_genes:
    for sample in LIS_samples:
      if sample == "": continue					# small bugfix for empty values
      # if sample's cohort gnomad AF exceeds cutoffs: skip to next sample
      sampleCohort = SAMPLE2COHORT[sample]
      cohortPassesFilters = Cohort2Filter[sampleCohort]
      if not cohortPassesFilters: continue
      # if sample is heterozygous for current variant: pass variant to DATA object for future parsing
      sampleGty_col = DIC_sample2col[sample]
      sampleGty     = LIS_line[sampleGty_col]
      if sampleGty == "Heterozygote":
        if gene not in DATA: DATA[gene]={}
        if sample not in DATA[gene]: DATA[gene][sample]=[]
        DATA[gene][sample].append(variant)

f.close()

# push only compound hets into final data object for output
for gene in DATA:
  for sample in DATA[gene]:
    if len(DATA[gene][sample]) > 1:
      if gene not in COMPOUND_HETS: COMPOUND_HETS.update({gene:{}})
      COMPOUND_HETS[gene].update({sample: DATA[gene][sample]})

# run through final object and print results, gene by gene
for gene in COMPOUND_HETS:
  with open(gene + '.compound_hets', 'w') as f:
    max_vars = max([ len(COMPOUND_HETS[gene][sample]) for sample in COMPOUND_HETS[gene] ])
    STR_header = '\t'.join(['sample','#variants','\t'.join(['var' + str(i) for i in range(1,max_vars)])])
    STR_data = ""
    f.write(STR_header + '\n')
    for sample in COMPOUND_HETS[gene]:
      LIS_out = COMPOUND_HETS[gene][sample]
      STR_out = '\t'.join([sample, str(len(LIS_out)), '\t'.join(LIS_out)])
      STR_data = '\n'.join([STR_data, STR_out]) if STR_data else STR_out
    f.write(STR_data)
