#!/bin/bash

gene_list=$2
BASE_DIR=$1
co=$3
script=$4

for gene in $(cat $gene_list);
    do for cohort in $co;
        do for DP in 30x 50x;
        do Rscript $script/R.SKAT --dir $BASE_DIR/SKAT --gene $gene --cohort $cohort --depth $DP;
        done;
    done;
done; 2>&1|tee SKAT.Launch.log