#!/bin/bash

read BASE_DIR gene_list gene_bed output_name sample_list geno cohort cohort_folder core <<< $@

module load gatk/4.1.2.0

if [[ -z $BASE_DIR ]]; then echo "ERROR: BASE_DIR (1st arg) not specified"; exit 42; fi
if [[ -z $gene_list ]]; then echo "ERROR: gene_list (2nd arg) not specified"; exit 42; fi
if [[ ! -f $BASE_DIR/$gene_list ]]; then echo "ERROR: gene_list (2nd arg) does not exist"; exit 42; fi
if [[ $(awk -F "\t" 'NF != 1' $gene_list) ]]; then echo "ERROR: Unexpected format for gene_list (2nd arg)"; exit 42; fi
if [[ -z $gene_bed ]]; then echo "ERROR: gene_bed (3rd arg) not specified"; exit 42; fi
if [[ ! -f $BASE_DIR/$gene_bed ]]; then echo "ERROR: gene_bed (3rd arg) does not exist"; exit 42; fi
if [[ $(awk -F "\t" 'NF != 4' $gene_bed) ]]; then echo "ERROR: Unexpected format for gene_bed (3rd arg)"; exit 42; fi
if [[ -z $output_name ]]; then echo "ERROR: output_name (4th arg) not specified"; exit 42; fi
if [[ -z $sample_list ]]; then echo "ERROR: sample_list (5th arg) not specified"; exit 42; fi
if [[ -z $geno ]]; then echo "ERROR: geno (6th arg) not specified"; exit 42; fi
if [[ $(awk -F "\t" 'NF != 1' $sample_list) ]]; then echo "ERROR: Unexpected format for sample_list (5th arg)"; exit 42; fi
if [[ -z $cohort ]]; then echo "ERROR: cohort (7th arg) not specified"; exit 42; fi
if [[ -z $cohort_folder ]]; then echo "ERROR: cohort_folder (8th arg) not specified"; exit 42; fi
if [[ ! -f $cohort_folder/covar_$cohort.txt ]]; then echo "ERROR: cohort_folder does not contain covar_$cohort.txt"; exit 42; fi
if [[ ! -f $cohort_folder/sex_$cohort.txt ]]; then echo "ERROR: cohort_folder does not contain sex_$cohort.txt"; exit 42; fi
if [[ ! -f $cohort_folder/pheno_$cohort.txt ]]; then echo "ERROR: cohort_folder does not contain pheno_$cohort.txt"; exit 42; fi
if [[ ! -f $cohort_folder/$cohort.samples.list ]]; then echo "ERROR: cohort_folder does not $cohort.samples.list"; exit 42; fi
if [[ -z $core ]]; then echo "ERROR: core (9th arg) not specified"; exit 42; fi

SCRIPT_FOLDER=~/runs/eyu8/data/MIPVar/Scripts
echo "STEP 0 START"
bash $SCRIPT_FOLDER/Processing.step00.FolderSetup.merged.sh $BASE_DIR $gene_list $cohort

echo "STEP 1 START"
srun -t 0:30:0 --mem=40G -c $core $SCRIPT_FOLDER/Processing.step01.getOnlyMySamples.preAnnotated.sh $BASE_DIR $output_name $gene_bed $sample_list $core

echo "STEP 2 START"
srun -t 2:0:0 --mem=4G -c 1 $SCRIPT_FOLDER/Processing.step02.maskCallsLower25GF.sh $output_name.vcf 0.$geno

echo "STEP 3 START (renaming file)"
cp $BASE_DIR/$output_name"_GF"$geno".vcf" $BASE_DIR/$output_name"_GF"$geno"_annotated.vcf"
gatk IndexFeatureFile -F $BASE_DIR/$output_name"_GF"$geno"_annotated.vcf"

echo "STEP 4 START"
srun -t 2:0:0 --mem=12G -c 3 parallel 'echo "STEP 4 START DP" {1}; \
    bash {3}/Processing.step04.removeLowQualVariants_GF_GQ_DP_MISS10_biallelic.sh {2}"_"GF"{4}"_annotated.vcf {1} 2>&1;' ::: 15 30 50 ::: $output_name ::: $SCRIPT_FOLDER ::: $geno

echo "STEP 5 START"
srun -t 0:30:0 --mem=12G -c 3 parallel 'echo "STEP 5 START DP" {1}; \
    bash {3}/Processing.step05.flagBadSamplesAndCreateExclusionList.sh {2}"_GF{4}_annotated_GQ30_DP"{1}"_"MISS10_filtered.vcf ;' ::: 15 30 50 ::: $output_name ::: $SCRIPT_FOLDER ::: $geno

echo "STEP 6 START"
srun -t 0:30:0 --mem=12G -c 3 parallel 'echo "STEP 6 START DP" {1}; \
        bash {3}/Processing.step06.excludeBadSamples.sh {2}"_GF{4}_annotated_GQ30_DP"{1}"_MISS10_filtered.vcf" {2}"_GF25_annotated_GQ30_DP"{1}"_MISS10_filtered.vcf.10PercentShitSamplesToExclude" 1;' ::: 15 30 50 ::: $output_name ::: $SCRIPT_FOLDER ::: $geno

echo "STEP 7 START"
srun -t 0:30:0 --mem=40G -c 10 parallel 'echo "STEP 7 START DP" {1} "COHORT" {2}; \
        bash {4}/Processing.step07.selectByCohorts.sh {3}"_GF{6}_annotated_GQ30_DP"{1}"_MISS10_filtered_cleaned.vcf" {2} {1} {5} 1;' ::: 15 30 50 ::: $cohort ::: $output_name ::: $SCRIPT_FOLDER ::: $cohort_folder ::: $geno

echo "STEP 8 START"
srun -t 0:30:0 --mem=12G -c 3 $SCRIPT_FOLDER/Processing.step08.selectByGene.parallel.1cohort.sh $BASE_DIR $gene_list $SCRIPT_FOLDER $gene_bed $cohort

echo "STEP 9 START"
srun -t 0:30:0 --mem=40G -c 10 parallel 'echo "STEP 9 START DP" {1} "COHORT" {2} "GENE" {3}; \
        bash {4}/Processing.step09.filterPlink_and_LogisticRegression.sh {5} {3} {2} {1} {6};' ::: 15 30 50 ::: $cohort ::: $(cat $gene_list) ::: $SCRIPT_FOLDER ::: $BASE_DIR ::: $cohort_folder

echo "STEP 10 START"
srun -t 1:0:0 --mem=40G -c 10 parallel 'echo "STEP 10 START DP" {1} "COHORT" {2} "GENE" {3}; \
        bash {4}/Processing.step10.finalSelection.sh {5} {3} {2} {1} 1;' ::: 15 30 50 ::: $cohort ::: $(cat $gene_list) ::: $SCRIPT_FOLDER ::: $BASE_DIR

echo "STEP 11 START"
srun -t 2:0:0 --mem=12G -c 3 $SCRIPT_FOLDER/Processing.step11.setup.seg.runs.merged.sh $BASE_DIR $gene_list $cohort
