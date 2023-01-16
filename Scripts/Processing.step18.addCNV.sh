#!/bin/bash

module load gcc/7.3 r-bundle-bioconductor/3.9

BFILE=$1
CNV_FILE=$2
plink --bfile $BFILE --recode --out $BFILE 

Rscript ~/runs/eyu8/soft/MIPVar/Scripts/Processing.step18.addCNV.R $BFILE.ped $BFILE.map $CNV_FILE $BFILE.SETID

plink --file ${BFILE}_wCNV --make-bed --out ${BFILE}_wCNV

plink --bfile ${BFILE}_wCNV --recode A --out ${BFILE}_wCNV
