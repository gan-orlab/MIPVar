#!/bin/bash

sample=$1
snp=$2
vcf=$3

cat <(awk 'BEGIN{FS=OFS="\t"}{if($0 ~ /^#CHROM/){print}}' <(head -1000 $vcf)) <(grep -m 1 $snp $vcf) | awk -v snp=$snp -v sample=$sample \
'BEGIN{FS=OFS="\t"}{
 if ($0~/^#CHROM/) {split($0,colnames,"\t"); next};
 print "Looking for "sample" "snp;
 for (i=10; i<=NF; i++) {
    if (colnames[i] == sample){
        print sample,snp,$9,$i
    }
 }
 }'
