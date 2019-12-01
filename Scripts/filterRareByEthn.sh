#!/bin/bash

cohort=$1
output=$2
cutoff=${3:-0.01}

awk -v cutoff=$cutoff 'BEGIN{FS=OFS="\t"}{
  if (NR==FNR) {sample2cohort[$1]=$6; next};
  if (FNR==1) {print; next};
  EF=0; AF=0; ES=0; AS=0;
  if ($33<cutoff&&$42<cutoff) EF=1;
  if ($30<cutoff&&$39<cutoff) AF=1;
  if (AF==0&&EF==0) next;
  split($52,probands,","); split($53,controls,",");
  for (i in probands) {
    if (AS==1&&ES==1) break
    sample=probands[i];
    if (sample2cohort[sample]==1) {ES=1} else {AS=1};
  };
  for (i in controls) {
    if (AS==1&&ES==1) break
    sample=controls[i];
    if (sample2cohort[sample]==1) {ES=1} else {AS=1};
  }
  if ((AF==1&&AS==1)||(EF==1&&ES==1)) print
}' $cohort $output
