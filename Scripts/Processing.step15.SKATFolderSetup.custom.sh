#!/bin/bash


BASE_DIR=$1
gene_list=$2
cohort=$3
cat $gene_list | while read gene
do

for co in $cohort; do mkdir -p $BASE_DIR/SKAT/$gene/$co/{30,50}x ; done

done
