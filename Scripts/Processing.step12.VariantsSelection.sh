#!/bin/bash

BASE_DIR=$1

for i in FC NY ISR;
    do bash ~/MIPVar/Scripts/NEW.filterRareByEthn_CheckingMissingGnomAD.sh ~/MIPVar/covar_files/2020_01/covar_$i.txt segregation.analysis/$i/30x/PD.$i.30x.final.output > $BASE_DIR/segregation.analysis/$i/30x/PD.$i.30x.final.OnlyRare.output;
    bash ~/MIPVar/Scripts/select_gene_nosyn.sh $BASE_DIR/segregation.analysis/$i/30x/PD.$i.30x.final.OnlyRare.output > $BASE_DIR/segregation.analysis/$i/30x/PD.$i.30x.final.OnlyRare.OnlyFunct.PARK2.output;
    bash ~/MIPVar/Scripts/split_carrier_PARK2.sh $BASE_DIR/segregation.analysis/$i/30x/PD.$i.30x.final.OnlyRare.OnlyFunct.PARK2.output > $BASE_DIR/segregation.analysis/$i/30x/PD.$i.30x.final.OnlyRare.OnlyFunct.PARK2.tab;
done
