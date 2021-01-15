#!/bin/bash

gene_list=$2
BASE_DIR=$1
script=$3
covar=$4

for gene in $(cat $gene_list);
    do for cohort in FC NY ISR;
        do for DP in 30x 50x;
        do Rscript $script/SKAT.R --dir $BASE_DIR/SKAT/$gene/$cohort/$DP --prefix ${gene}_${cohort}_$DP --covar $covar;
        done;
    done;
done; 2>&1|tee SKAT.Launch.log
