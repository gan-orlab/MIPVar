#!/bin/bash

cohort=$1
output=$2
cutoff=${3:-0.01}

awk -v cutoff=$cutoff 'BEGIN{FS=OFS="\t"}{
  if (NR==FNR) {sample2cohort[$1]=$6; next};
  if (FNR==1) {
    print;
    for (i=1; i<=NF; i++) {
      if ($i ~ /ASJ exome/)  cAE = i;
      if ($i ~ /ASJ genome/) cAG = i;
      if ($i ~ /NFE exome/)  cEE = i;
      if ($i ~ /NFE genome/) cEG = i;
      if ($i ~ /Probands w. variant individual names/)          cNamesPro  = i;
      if ($i ~ /Familial controls w. variant individual names/) cNamesCtrl = i;
      if ($i ~ /F_A/) cFA = i;
      if ($i ~ /F_U/) cFU = i;
    }
    next;
  };
  EF=0; AF=0; ES=0; AS=0;
  if ( (($cEE<cutoff&&$cEG<cutoff) && ($cEE>0||$cEG>0)) || ($cEE<=0&&$cEG<=0&&$cFA<cutoff&&$cFU<cutoff)) EF=1;
  if ( (($cAE<cutoff&&$cAG<cutoff) && ($cAE>0||$cAG>0)) || ($cAE<=0&&$cAG<=0&&$cFA<cutoff&&$cFU<cutoff)) AF=1;
  if (AF==0&&EF==0){ print; next;}
  split($cNamesPro,probands,","); split($cNamesCtrl,controls,",");
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
  if(!((AF==1&&EF==1)||(AS==0&&EF==1&&ES==1)||(AF==1&&AS==1&&ES==0))) print
}' $cohort $output
