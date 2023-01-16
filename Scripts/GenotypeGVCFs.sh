#!/bin/bash

REF=${REF:-/lustre03/project/6001220/COMMON/soft/src/pipeline_exome.svn/data/reference/human_g1k_v37.fasta}

module load gatk/3.8

GVCF_LIST=$1
BED=$2
RUN=$3
DIR=$4

OUT=$DIR/$RUN.vcf

java -Xmx40g -jar $EBROOTGATK/GenomeAnalysisTK.jar -T GenotypeGVCFs -nt 10 --disable_auto_index_creation_and_locking_when_reading_rods -R $REF --intervals $BED $(printf " --variant %s " $(cat $GVCF_LIST)) --out $OUT 
