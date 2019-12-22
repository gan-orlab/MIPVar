#!/bin/bash

BASE_DIR=$1
for dp in 15 30 50; do for cohort in FC NY ISR; do cat $BASE_DIR/segregation.analysis/$cohort/${dp}x/PD.${cohort}.${dp}x.output | awk -F "\t" '{ if (NR==1 || $11 ~ /stop/ ||$11 ~ /nonsyn/ || $11 ~ /frame/ || ($11 ~ /intronic_splicing/ && $11 ~ /[+-][1-2]/)) print $0}' > $BASE_DIR/segregation.analysis/$cohort/${dp}x/PD.${cohort}.${dp}x.output.OnlyFunct.txt; done; done

for dp in 15 30 50; do for cohort in FC NY ISR; do cat $BASE_DIR/segregation.analysis/$cohort/${dp}x/PD.${cohort}.${dp}x.final.output | awk -F "\t" '{ if (NR==1 || $19 ~ /stop/ ||$19 ~ /nonsyn/ || $19 ~ /frame/ || ($19 ~ /intronic_splicing/ && $19 ~ /[+-][1-2]/)) print $0}' > $BASE_DIR/segregation.analysis/$cohort/${dp}x/PD.${cohort}.${dp}x.final.output.OnlyFunct.txt; done; done
