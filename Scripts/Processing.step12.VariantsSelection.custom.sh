#!/bin/bash

BASE_DIR=$1
cohort=$2

for dp in 30x 50x;
    do for i in $cohort;
        do bash ~/MIPVar/Scripts/NEW.filterRareByEthn_CheckingMissingGnomAD.sh ~/MIPVar/covar_files/2020_01/covar_$i.txt segregation.analysis/$i/$dp/PD.$i.$dp.final.output > $BASE_DIR/segregation.analysis/$i/$dp/PD.$i.$dp.final.output.clean.OnlyRareAll.txt;
    done
done
