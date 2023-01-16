#!/bin/bash

gene_list=$2
BASE_DIR=$1
co=$4
script=$3
covar=$5
for gene in $(cat $gene_list);
    do for cohort in $co;
        do for DP in 30x 50x;
        do Rscript $script/SKAT.R --dir $BASE_DIR/SKAT/ --prefix $gene/$co/$DP/${gene}_${co}_${DP} --covar $covar;
        done;
    done;
done; 2>&1|tee SKAT.Launch.log
