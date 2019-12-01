#!/bin/bash


BASE_DIR=$1
gene_list=$2

cat $gene_list | while read gene
do

for cohort in $3; do mkdir -p $BASE_DIR/$gene/$cohort/{15,30,50}x/analysis ; done

done
