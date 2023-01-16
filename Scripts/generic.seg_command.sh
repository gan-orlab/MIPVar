#! /bin/bash

. $(dirname $0)/anno_include_list.sh

if [[ -z $run ]]; then echo "ERROR: you must include run as -v variable to qsub"; exit 42; fi
if [[ -z $VCF_LIST ]]; then echo "ERROR: you must inclue VCF_LIST (whitespace-separated, in quotes) as -v variable to qsub"; exit 42; fi

/lustre03/project/6004655/COMMUN/soft/src.links/segregation_vcf \
  --proband-var-reads 3 \
  --proband-coverage 6 \
  --proband-mutfreq 0.15 \
  --proband-genotype-quality 0 \
  --familial-control-var-reads 3 \
  --familial-control-coverage 6 \
  --familial-control-mutfreq 0.15 \
  --familial-control-genotype-quality 0 \
  $(printf " -v %s " $VCF_LIST) \
  -p $run.PED \
  -o $run.output \
  --verbose 2 \
  --use-format-low-stringency \
  --show-probands-with-variants 1000000 \
  --show-familial-controls-with-variants 1000000 \
  --show-all-variants \
  $(printf " --add-info %s " $anno_include_list) \
>$run.setup 2>$run.err
