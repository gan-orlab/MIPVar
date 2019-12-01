#!/bin/bash

#this is the step to filter all variants with genotype frequency of below 25% 
#it takes takes vcf as input (cutoff is precoded, but can be modified to be a variable if needed)

vcf=$1

cutoff=${2:-0.25}

out=$(basename $vcf|sed "s/.vcf$/_GF$(echo $cutoff|cut -d. -f2).vcf/g")

awk -v cutoff=$cutoff '
  function sum(array){
    s=0
    for (j in array) {s+=array[j]}
    return s
  }
  function mostFrequentALT(array){
    delete array[1]
    asort(array)
    return array[length(array)]
  }
  BEGIN{FS=OFS="\t"}
  {
  if ($0~/#/) {print; next}
  split($9,FORMAT,":")
  for (i in FORMAT) if (FORMAT[i]=="AD") field=i
  for (i=10; i<=NF; i++) {
    if ($i~/^0\/0/||$i~/^\.\/\./) continue
    split($i,a,":")
    split(a[field],AD,",")
    DENOM = sum(AD)
    NUM   = mostFrequentALT(AD)
    if (DENOM == 0) {freq = 0} else {freq = NUM / DENOM}
    if (freq < cutoff) $i = "./."
  }
  print $0
}' $vcf > $out
