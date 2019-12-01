#!/bin/bash

read smallFile bigFile <<< $@

header () 
{ 
    read file sep <<< $@;
    sep=${sep:-"\t"};
    head -n1 $file | awk -F"$sep" 'BEGIN{OFS="\t"}{for (i=1; i<=NF; i++) print i,$i}'
}

colCutoff=$[$(header $bigFile |awk -F"\t" '$2=="Family members"'|cut -f1)+1]

awk 'BEGIN{FS=OFS="\t"}{
  key=$2":"$3":"$4":"$5;
  if (NR==FNR&&FNR>1) {a[key]=1; next};
  if (NR>1&&FNR==1) {print "#homoz","homoz",$0; next}
  if (key in a) {
    delete hits; c=0
    split($63,samples,",");
    for (i in samples) {
      sample=samples[i]
      col=64+((i-1)*6)
      if ($col ~ /Homo/) {
        c++; hits[c]=sample
      }
    }
    if (length(hits)==0) next
    homos=""
    for (i in hits) homos=homos","hits[i]
    gsub(/^,/,"",homos)
    print c,homos,$0
  }
}' $smallFile $bigFile | cut -f 1-$colCutoff > $(basename $smallFile).Homoz
