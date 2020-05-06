#!/bin/bash

output=$1

awk 'BEGIN{FS=OFS="\t"}{
  if (FNR==1) {
    print
    for (i=1; i<=NF; i++) {
      if ($i ~ /Gene symbol (Gene)/) gene = i;
      if ($i ~ /Variant function type (VFT)/) var = i;
    }
    next;
  };
  if ($gene ~ /PARK2/){
    print
  }
}' $output
