#!/bin/bash

BASE_DIR=$1

for dp in 15 30 50;
    do for cohort in FC NY; do \
    awk -F "\t" '{if (NR==1||($26<0.01&&$35<0.01)) print $0}' $BASE_DIR/segregation.analysis/$cohort/${dp}x/PD.$cohort.${dp}x.final.output.OnlyFunct.txt > $BASE_DIR/segregation.analysis/$cohort/${dp}x/PD.$cohort.${dp}x.final.output.clean.OnlyRareFunct.txt;
done

awk -F "\t" '{if (NR==1||($23<0.01&&$32<0.01)) print $0}' $BASE_DIR/segregation.analysis/ISR/${dp}x/PD.ISR.${dp}x.final.output.OnlyFunct.txt > $BASE_DIR/segregation.analysis/ISR/${dp}x/PD.ISR.${dp}x.final.output.clean.OnlyRareFunct.txt;
done

for dp in 15 30 50;
    do for cohort in FC NY; do \
    awk -F "\t" '{if (NR==1||($25<0.01&&$34<0.01)) print $0}' $BASE_DIR/segregation.analysis/$cohort/${dp}x/PD.$cohort.${dp}x.output.OnlyFunct.txt > $BASE_DIR/segregation.analysis/$cohort/${dp}x/PD.$cohort.${dp}x.output.clean.OnlyRareFunct.txt;
    done

awk -F "\t" '{if (NR==1||($23<0.01&&$32<0.01)) print $0}' $BASE_DIR/segregation.analysis/ISR/${dp}x/PD.ISR.${dp}x.output.OnlyFunct.txt > $BASE_DIR/segregation.analysis/ISR/${dp}x/PD.ISR.${dp}x.output.clean.OnlyRareFunct.txt;
done
