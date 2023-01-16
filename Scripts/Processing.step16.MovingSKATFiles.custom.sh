#!/bin/bash

RUN_DIR=$1
gene_list=$2
co=$3

for cohort in $co;
    do for gene in $(cat $gene_list);
        do for type in bed bim fam;
            do for DP in 30 50;
               do cp $RUN_DIR/$gene/$cohort/${DP}x/analysis/${gene}_${cohort}_DP${DP}_geno10_ind10_hwe_testmiss.${type} $RUN_DIR/SKAT/$gene/$cohort/${DP}x/${gene}_${cohort}_${DP}x.${type}
            done
        done
    done
done
