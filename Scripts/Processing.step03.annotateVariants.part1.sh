#!/bin/bash

#this step will add rs numbers and then annotate the vcf using annovar; it takes vcf as input

#run script in the directory with vcf
#set your BASE_DIR to the directory where your original extracted vcf is located 
#GATK37, REF, vcf2annovar will be taken from Dan's files
#DBSNP is the file containing rs number information that has to hardcoded in the script
#annotation_list contains the list of annovar annotations that you want to include 


vcf=$1
core=$2
if [[ ! -s $vcf ]]; then echo "ERROR: vcf (1st arg) not specified, empty or does not exist"; exit 42; fi

BASE_DIR=$3
GATK37=~/projects/def-grouleau/COMMON/soft/lib/java/GATK/GenomeAnalysisTK-3.8/dist/GenomeAnalysisTK.jar
REF=~/projects/def-grouleau/COMMON/soft/src/pipeline_exome.svn/data/reference/human_g1k_v37.fasta
DBSNP=~/projects/def-grouleau/COMMON/runs/vrudakov/Thesis/35genes//Homo_sapiens.GRCh37.dbSNP150.vcf.gz
vcf2annovar=~/projects/def-grouleau/COMMON/soft/src/pipeline_exome.svn/soft/packages/VarAnnot/vcf2annovar.pl
annotation_list=~/projects/def-grouleau/COMMON/runs/vrudakov/Thesis/35genes/annotations.to.include

vcf_dbsnp=$(echo $vcf|sed 's/.vcf$/_dbSNP.vcf/g')
vcf_annovar=$(echo $vcf_dbsnp|sed 's/.vcf$/_annovar.vcf/g')
vcf_final=$(echo $vcf|sed 's/.vcf/_annotated.vcf/g')

java -Xmx40g -jar $GATK37 -T VariantAnnotator -R $REF -V $vcf --dbsnp $DBSNP -o $vcf_dbsnp -nt $core

