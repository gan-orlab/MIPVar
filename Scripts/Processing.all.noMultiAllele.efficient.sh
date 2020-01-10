#!/bin/bash

read BASE_DIR gene_list gene_bed output_name sample_list cohort_folder core <<< $@

PARAM="--mem=40G --time=2:0:0 --account=rrg-grouleau-ac"

SCRIPT_FOLDER=~/runs/eyu8/data/MIPVar/Scripts

if [[ -z $BASE_DIR ]]; then echo "ERROR: BASE_DIR (1st arg) not specified"; exit 42; fi
if [[ -z $gene_list ]]; then echo "ERROR: gene_list (2nd arg) not specified"; exit 42; fi
if [[ $(awk -F "\t" 'NF != 1' $gene_list) ]]; then echo "ERROR: Unexpected format for gene_list (2nd arg)"; exit 42; fi
if [[ -z $gene_bed ]]; then echo "ERROR: gene_bed (3rd arg) not specified"; exit 42; fi
if [[ $(awk -F "\t" 'NF != 4' $gene_bed) ]]; then echo "ERROR: Unexpected format for gene_bed (3rd arg)"; exit 42; fi
if [[ -z $output_name ]]; then echo "ERROR: output_name (4th arg) not specified"; exit 42; fi
if [[ -z $sample_list ]]; then echo "ERROR: sample_list (5th arg) not specified"; exit 42; fi
if [[ $(awk -F "\t" 'NF != 1' $sample_list) ]]; then echo "ERROR: Unexpected format for sample_list (5th arg)"; exit 42; fi
if [[ -z $cohort_folder ]]; then echo "ERROR: cohort_folder (6th arg) not specified"; exit 42; fi
if [[ ! -f $cohort_folder/covar_FC.txt ]]; then echo "ERROR: cohort_folder does not contain covar_FC.txt"; exit 42; fi
if [[ ! -f $cohort_folder/covar_NY.txt ]]; then echo "ERROR: cohort_folder does not contain covar_NY.txt"; exit 42; fi
if [[ ! -f $cohort_folder/covar_ISR.txt ]]; then echo "ERROR: cohort_folder does not contain covar_ISR.txt"; exit 42; fi
if [[ ! -f $cohort_folder/sex_FC.txt ]]; then echo "ERROR: cohort_folder does not contain sex_FC.txt"; exit 42; fi
if [[ ! -f $cohort_folder/sex_NY.txt ]]; then echo "ERROR: cohort_folder does not contain sex_NY.txt"; exit 42; fi
if [[ ! -f $cohort_folder/sex_ISR.txt ]]; then echo "ERROR: cohort_folder does not contain sex_ISR.txt"; exit 42; fi
if [[ ! -f $cohort_folder/pheno_FC.txt ]]; then echo "ERROR: cohort_folder does not contain pheno_FC.txt"; exit 42; fi
if [[ ! -f $cohort_folder/pheno_NY.txt ]]; then echo "ERROR: cohort_folder does not contain pheno_NY.txt"; exit 42; fi
if [[ ! -f $cohort_folder/pheno_ISR.txt ]]; then echo "ERROR: cohort_folder does not contain pheno_ISR.txt"; exit 42; fi
if [[ ! -f $cohort_folder/FC.samples.list ]]; then echo "ERROR: cohort_folder does not FC.samples.list"; exit 42; fi
if [[ ! -f $cohort_folder/NY.samples.list ]]; then echo "ERROR: cohort_folder does not NY.samples.list"; exit 42; fi
if [[ ! -f $cohort_folder/ISR.samples.list ]]; then echo "ERROR: cohort_folder does not ISR.samples.list"; exit 42; fi
if [[ -z $core ]]; then echo "ERROR: core (7th arg) not specified"; exit 42; fi

echo "STEP 0 START"
bash $SCRIPT_FOLDER/Processing.step00.FolderSetup.sh $BASE_DIR $gene_list 
echo "STEP 1 START"
srun $PARAM --cpus-per-task=$core $SCRIPT_FOLDER/Processing.step01.getOnlyMySamples.noMultiAllele.part1.sh $BASE_DIR $output_name $gene_bed $sample_list $core
srun $PARAM -c 1 $SCRIPT_FOLDER/Processing.step01.getOnlyMySamples.noMultiAllele.part2.sh $BASE_DIR $output_name $gene_bed $sample_list $core
srun $PARAM --cpus-per-task=$core $SCRIPT_FOLDER/Processing.step01.getOnlyMySamples.noMultiAllele.part3.sh $BASE_DIR $output_name $gene_bed $sample_list $core
if [[ ! -f $BASE_DIR/$output_name"_GF25.vcf"  ]]; then echo "ERROR: STEP 1 failed"; exit 42; fi
echo "STEP 2 START"
bash $SCRIPT_FOLDER/Processing.step02.maskCallsLower25GF.sh $output_name.vcf 
echo "STEP 3 START"
srun $PARAM --cpus-per-task=$core $SCRIPT_FOLDER/Processing.step03.annotateVariants.part1.sh $output_name"_GF25.vcf" $core $BASE_DIR
srun $PARAM -c 1 $SCRIPT_FOLDER/Processing.step03.annotateVariants.part2.sh $output_name"_GF25.vcf" $BASE_DIR
if [[ ! -f $BASE_DIR/$output_name"_GF25_annotated.vcf"  ]]; then echo "ERROR: STEP 3 failed"; exit 42; fi
echo "STEP 4 START"

for dp in 15 30 50;
    do  echo "STEP 4 START DP $dp";
    srun $PARAM $SCRIPT_FOLDER/Processing.step04.removeLowQualVariants_GF_GQ_DP_MISS10.sh $output_name"_GF25_annotated.vcf" $dp ;
done

echo "STEP 5 START"
srun $PARAM --cpus-per-task=3 parallel 'echo "STEP 5 START DP" {1}; \
        bash {3}/Processing.step05.flagBadSamplesAndCreateExclusionList.sh {2}"_GF25_annotated_GQ30_DP"{1}"_"MISS10_filtered.vcf 2>&1;' ::: 15 30 50 ::: $output_name ::: $SCRIPT_FOLDER
echo "STEP 6 START"
srun $PARAM --cpus-per-task=3 parallel 'echo "STEP 6 START DP" {1}; \
    bash {3}/Processing.step06.excludeBadSamples.sh {2}"_GF25_annotated_GQ30_DP"{1}"_MISS10_filtered.vcf" {2}"_GF25_annotated_GQ30_DP"{1}"_MISS10_filtered.vcf.10PercentShitSamplesToExclude" 1;' ::: 15 30 50 ::: $output_name ::: $SCRIPT_FOLDER
echo "STEP 7 START"
for cohort in FC NY ISR;
    do srun --mem=80G --time=0:10:0 --account=rrg-grouleau-ac --cpus-per-task=3 parallel 'echo "STEP 7 START DP" {1} "COHORT" {2}; \
    bash {4}/Processing.step07.selectByCohorts.sh {3}"_GF25_annotated_GQ30_DP"{1}"_MISS10_filtered_cleaned.vcf" {2} {1} {5} 1;' ::: 15 30 50 ::: $cohort ::: $output_name ::: $SCRIPT_FOLDER ::: $cohort_folder;
done
echo "STEP 8 START"
srun $PARAM --cpus-per-task=9 $SCRIPT_FOLDER/Processing.step08.selectByGene.parallel.sh $BASE_DIR $gene_list $SCRIPT_FOLDER $gene_bed
echo "STEP 9 START"
srun $PARAM --cpus-per-task=$core parallel 'echo "STEP 9 START DP" {1} "COHORT" {2} "GENE" {3}; \
    bash {4}/Processing.step09.filterPlink_and_LogisticRegression.sh {5} {3} {2} {1} {6};' ::: 15 30 50 ::: FC NY ISR ::: $(cat $gene_list) ::: $SCRIPT_FOLDER ::: $BASE_DIR ::: $cohort_folder
echo "STEP 10 START"
srun $PARAM --cpus-per-task=$core parallel 'echo "STEP 10 START DP" {1} "COHORT" {2} "GENE" {3}; \
    bash {4}/Processing.step10.finalSelection.sh {5} {3} {2} {1} 1;' ::: 15 30 50 ::: FC NY ISR ::: $(cat $gene_list) ::: $SCRIPT_FOLDER ::: $BASE_DIR
echo "STEP 11 START"
srun $PARAM --cpus-per-task=9 $SCRIPT_FOLDER/Processing.step11.setup.seg.runs.sh $BASE_DIR $gene_list
