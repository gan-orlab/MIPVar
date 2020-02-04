#!/bin/bash

#Input a vcf, filter it down to all variants with GQ >= 30, DP >= ??, at least 90% of samples genotyped at that threshold.

#can be ran 3 times one by one OR can be put in a loop: for DP in 15 30 50; do bash script.sh yourfile.vcf $DP; done

# parse variables: read vcf and DPcutoff values from script inputs
read vcf DPcutoff <<< $@

# set constants
g1k_ref=~/projects/def-grouleau/COMMON/soft/src/pipeline_exome.svn/data/reference/human_g1k_v37.fasta
GATK37=~/projects/def-grouleau/COMMON/soft/lib/java/GATK/GenomeAnalysisTK-3.8/dist/GenomeAnalysisTK.jar
ANcutoff=$(head -1000 $vcf|grep CHROM|cut -f10-|wc -w|awk '{print int(2*$1*0.9)}')

# check inputs are ok
if [[ ! -s $vcf ]]; then echo "ERROR: input vcf (1st argument) not specified, empty or does not exist"; exit 42; fi
if [[ -z $DPcutoff || ! $DPcutoff -gt 0 ]]; then echo "ERROR: DP cutoff (2nd argument) not specified or not a positive integer"; exit 42; fi

# set dependent variables
tmp1Vcf=$(basename $vcf|sed "s/.vcf$/_GQ30_DP$DPcutoff.vcf/g")
tmp2Vcf=$(basename $tmp1Vcf|sed 's/.vcf$/_MISS10.vcf/g')
outVcf=$(basename $tmp2Vcf|sed 's/.vcf$/_filtered.vcf/g')

java -Xmx4g -jar $GATK37 \
-T VariantFiltration \
-R $g1k_ref \
-V $vcf \
-o $tmp1Vcf \
--genotypeFilterExpression "GQ < 30" \
--genotypeFilterName "GQ30" \
--genotypeFilterExpression "DP < $DPcutoff" \
--genotypeFilterName "DP$DPcutoff" \
--setFilteredGtToNocall \
--missingValuesInExpressionsShouldEvaluateAsFailing;

java -Xmx4g -jar $GATK37 \
-T VariantFiltration \
-R $g1k_ref \
-V $tmp1Vcf \
-o $tmp2Vcf \
--filterExpression "AN < $ANcutoff" \
--filterName "MISS10" \
--missingValuesInExpressionsShouldEvaluateAsFailing;

java -Xmx4g -jar $GATK37 \
-T SelectVariants \
-R $g1k_ref \
-V $tmp2Vcf \
-o $outVcf \
--excludeFiltered \
--excludeNonVariants

