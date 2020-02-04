#!/bin/bash

##Set DIR in your seg analysis folder


read DIR cohort DP <<< $@
types="CADD Encode Funct LOF NS All"


for type in $types; do
  cat $DIR/$cohort/$DP/PD.$cohort.$DP.final.output.clean.OnlyRare$type.txt | awk -v cohort=$cohort -v DP=$DP -v type=$type 'BEGIN{FS=OFS="\t"}{if(NR>1) print $26"_"cohort""DP"_Rare"type,$6,$26,cohort"_"DP}' >> $DIR/Combined.setprep
done

#$cohort.$DP.Rare$type.setprep
