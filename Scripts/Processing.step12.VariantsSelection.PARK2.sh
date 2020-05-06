#!/bin/bash

BASE_DIR=$1

for dp in 30x 50x;
    do for i in FC NY ISR;
        do bash ~/MIPVar/Scripts/NEW.filterRareByEthn_CheckingMissingGnomAD.sh ~/MIPVar/covar_files/2020_03/covar_$i.txt segregation.analysis/$i/$dp/PD.$i.$dp.final.output > $BASE_DIR/segregation.analysis/$i/$dp/PD.$i.$dp.final.output.clean.OnlyRareAll.txt;
        bash ~/MIPVar/Scripts/select_PARK2_nosyn.sh $BASE_DIR/segregation.analysis/$i/$dp/PD.$i.$dp.final.output.clean.OnlyRareAll.txt > $BASE_DIR/segregation.analysis/$i/$dp/PD.$i.$dp.final.OnlyRare.OnlyFunct.PARK2.output;
        bash ~/MIPVar/Scripts/split_carrier_PARK2.sh $BASE_DIR/segregation.analysis/$i/$dp/PD.$i.$dp.final.OnlyRare.OnlyFunct.PARK2.output > $BASE_DIR/segregation.analysis/$i/$dp/PD.$i.$dp.final.OnlyRare.OnlyFunct.PARK2.tab;
    done
done
