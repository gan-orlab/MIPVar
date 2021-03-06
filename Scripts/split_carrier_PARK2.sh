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
      if ($i ~ /Probands w. variant individual names/) case_name = i;
      if ($i ~ /Familial controls w. variant individual names/) control_name = i;
    }
    next;
  };
  if($name > 0 ){
    split($case_name,probands,",");
    split($control_name,family,",");
    split($anno,transcript,"|");
    for (i in transcript){ if (transcript[i] ~ /NM_004562/) PARK2 = transcript[i]};
    chr_pos = $chr":"$pos;
    for (i in probands){
        print probands[i],chr_pos,$rsid,$ref,$alt,PARK2;
    }
    for (i in family){
        print family[i],chr_pos,$rsid,$ref,$alt,PARK2;
    }
  }
}' $output
