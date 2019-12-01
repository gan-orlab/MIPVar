#!/bin/bash

read BASE_DIR gene cohort_name DP <<< $@
if [[ -z $gene ]]; then echo "ERROR: gene (1st arg) not specified"; exit 42; fi
if [[ -z $DP || ! $DP -gt 0 ]]; then echo "ERROR: depth (2nd arg) not specified"; exit 42; fi
if [[ -z $cohort_name ]]; then echo "ERROR: cohort name (3rd arg) not specified"; exit 42; fi

REF=~/projects/def-grouleau/COMMON/soft/src/pipeline_exome.svn/data/reference/human_g1k_v37.fasta
GATK37=~/projects/def-grouleau/COMMON/soft/lib/java/GATK/GenomeAnalysisTK-3.8/dist/GenomeAnalysisTK.jar

#INTERVALS=$BASE_DIR/$gene/$cohort_name/${DP}x/${gene}_${cohort_name}_DP${DP}.final.intervals
INTERVALS=$BASE_DIR/$gene/$cohort_name/${DP}x/${gene}_${cohort_name}_DP${DP}_geno10_ind10_hwe_testmiss.vcf
SAMPLE_LIST=$BASE_DIR/$gene/$cohort_name/${DP}x/${gene}_${cohort_name}_DP${DP}.final.samples
vcf=$BASE_DIR/$gene/$cohort_name/${DP}x/$gene.$cohort_name.DP$DP.vcf
if [[ ! -s $INTERVALS ]]; then echo "ERROR: intervals list $INTERVALS empty or does not exist"; exit 42; fi
if [[ ! -s $SAMPLE_LIST ]]; then echo "ERROR: sample list $SAMPLE_LIST empty or does not exist"; exit 42; fi
if [[ ! -s $vcf ]]; then echo "ERROR: input vcf empty or does not exist; name should be $vcf"; exit 42; fi

output=$BASE_DIR/$gene/$cohort_name/${DP}x/analysis/$gene.$cohort_name.DP$DP.final.vcf

java -Xmx4g -jar $GATK37 -T SelectVariants -R $REF -V $vcf -o $output -L $INTERVALS -sf $SAMPLE_LIST -env --ALLOW_NONOVERLAPPING_COMMAND_LINE_SAMPLES 
