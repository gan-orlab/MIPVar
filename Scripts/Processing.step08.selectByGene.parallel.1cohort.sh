#!/bin/bash

read BASE_DIR gene_list SCRIPT_FOLDER gene_bed cohort <<< $@

for gene in $(cat $gene_list);
do parallel 'echo "STEP 8 START DP" {1} "COHORT" {2} "GENE" {3}; bash {4}/Processing.step08.selectByGene.sh {5} {6} {3} {2} {1} 1;' ::: 15 30 50 ::: $cohort ::: $gene ::: $SCRIPT_FOLDER ::: $BASE_DIR ::: $gene_bed;
done
