#!/bin/bash

BASE_DIR=$1
script=$2
covar=$3
for dp in 30x 50x;
    do for i in FC NY ISR;
        do bash $script/NEW.filterRareByEthn_CheckingMissingGnomAD.sh $covar/covar_$i.txt segregation.analysis/$i/$dp/PD.$i.$dp.final.output > $BASE_DIR/segregation.analysis/$i/$dp/PD.$i.$dp.final.output.clean.OnlyRareAll.txt;
    done
done
