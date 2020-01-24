#!/bin/bash

output=$1

awk 'BEGIN{FS=OFS="\t"}{
  if (FNR==1) {
    print "Sample","Position","SNP","Reference Allele","Alternate Allele","Variant Info";
    for (i=1; i<=NF; i++) {
      if ($i ~ /^Chr$/) chr = i;
      if ($i ~ /^Position$/) pos = i;
      if ($i ~ /^SNP$/) rsid = i;
      if ($i ~ /Reference Allele/) ref = i;
      if ($i ~ /Mutant Allele/) alt = i;
      if ($i ~ /Detailed annotation of the variant/) anno = i;
      if ($i ~ /Probands w. variant individual names/) name = i;
    }
    next;
  };
  if($name > 0 ){
    split($name,probands,",");
    split($anno,transcript,"|");
    chr_pos = $chr":"$pos;
    for (i in probands){
        print probands[i],chr_pos,$rsid,$ref,$alt,$anno;
    }
  }
}' $output
