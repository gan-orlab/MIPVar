#!/bin/bash

#I use variables, for readability
#Takes 2 arguments: 1st is the vcf from the previous step and 2nd is the exclusion list for the vcf !!!make sure you use the correct exclusion list according to DP



read vcf excludeSampleList core <<< $@
if [[ ! -s $vcf ]]; then echo "ERROR: input vcf (1st arg) not specified, empty or does not exist"; exit 42; fi
if [[ ! -s $excludeSampleList ]]; then echo "ERROR: exclude_sample_list (2nd arg) not specified, empty or does not exist"; exit 42; fi

REF=~/projects/def-grouleau/COMMON/soft/src/pipeline_exome.svn/data/reference/human_g1k_v37.fasta
output=$(basename $vcf|sed 's/.vcf$/_cleaned.vcf/g')

java -Xmx10g -jar ~/projects/def-grouleau/COMMON/soft/lib/java/GATK/GenomeAnalysisTK-3.8/dist/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V $vcf -o $output --exclude_sample_file $excludeSampleList -env -nt $core
