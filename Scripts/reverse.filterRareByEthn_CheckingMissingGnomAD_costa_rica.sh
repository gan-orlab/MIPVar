#!/bin/bash

output=$1
cutoff=${2:-0.01}

awk -v cutoff=$cutoff 'BEGIN{FS=OFS="\t"}{
  if (FNR==1) {
    print;
    for (i=1; i<=NF; i++) {
      if ($i ~ /ALL exome/)  cEE = i;
      if ($i ~ /ALL genome/) cEG = i;
      if ($i ~ /Probands w. variant individual names/)          cNamesPro  = i;
      if ($i ~ /Familial controls w. variant individual names/) cNamesCtrl = i;
      if ($i ~ /F_A/) cFA = i;
      if ($i ~ /F_U/) cFU = i;
    }
    next;
  };
  EF=0; ES=0;
  if ( (($cEE<cutoff&&$cEG<cutoff) && ($cEE>0||$cEG>0)) || ($cEE<=0&&$cEG<=0&&$cFA<cutoff&&$cFU<cutoff)) EF=1;
  if (EF==0){ print;}
}' $cohort $output
