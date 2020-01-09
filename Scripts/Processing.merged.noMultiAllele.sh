#!/bin/bash

read BASE_DIR gene_list gene_bed output_name sample_list geno cohort cohort_folder core <<< $@

if [[ -z $BASE_DIR ]]; then echo "ERROR: BASE_DIR (1st arg) not specified"; exit 42; fi
if [[ -z $gene_list ]]; then echo "ERROR: gene_list (2nd arg) not specified"; exit 42; fi
if [[ $(awk -F "\t" 'NF != 1' $gene_list) ]]; then echo "ERROR: Unexpected format for gene_list (2nd arg)"; exit 42; fi
if [[ -z $gene_bed ]]; then echo "ERROR: gene_bed (3rd arg) not specified"; exit 42; fi
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

SCRIPT_FOLDER=~/runs/eyu8/data/MIPVar/Scripts
echo "STEP 0 START"
bash $SCRIPT_FOLDER/Processing.step00.FolderSetup.merged.sh $BASE_DIR $gene_list $cohort
echo "STEP 1 START"
bash $SCRIPT_FOLDER/Processing.step01.getOnlyMySamples.noMultiAllele.sh $BASE_DIR $output_name $gene_bed $sample_list $core
echo "STEP 2 START"
bash $SCRIPT_FOLDER/Processing.step02.maskCallsLower25GF.sh $output_name.vcf 0.$geno
echo "STEP 3 START"
bash $SCRIPT_FOLDER/Processing.step03.annotateVariants.sh $output_name"_"GF$geno.vcf $core $BASE_DIR

for dp in 15 30 50;
do 
    echo "STEP 4 START DP" $dp;
    bash $SCRIPT_FOLDER/Processing.step04.removeLowQualVariants_GF_GQ_DP_MISS10.sh $output_name"_"GF$geno"_"annotated.vcf $dp $core;
    echo "STEP 5 START DP" $dp;
    bash $SCRIPT_FOLDER/Processing.step05.flagBadSamplesAndCreateExclusionList.sh $output_name"_"GF$geno"_"annotated_GQ30_DP$dp"_"MISS10_filtered.vcf;
    echo "STEP 6 START DP" $dp;
    bash $SCRIPT_FOLDER/Processing.step06.excludeBadSamples.sh $output_name"_"GF$geno"_"annotated_GQ30_DP$dp"_"MISS10_filtered.vcf $output_name"_"GF$geno"_"annotated_GQ30_DP$dp"_"MISS10_filtered.vcf.10PercentShitSamplesToExclude $core;
    echo "STEP 7 START DP" $dp "COHORT" $cohort;
    bash $SCRIPT_FOLDER/Processing.step07.selectByCohorts.sh $output_name"_"GF$geno"_"annotated_GQ30_DP$dp"_"MISS10_filtered_cleaned.vcf $cohort $dp $cohort_folder $core;
    for gene in $(cat $gene_list);
    do
        echo "STEP 8 START DP" $dp "COHORT" $cohort "GENE" $gene;
        bash $SCRIPT_FOLDER/Processing.step08.selectByGene.sh $BASE_DIR $gene_bed $gene $cohort $dp $core;
        echo "STEP 9 START DP" $dp "COHORT" $cohort "GENE" $gene;
        bash $SCRIPT_FOLDER/Processing.step09.filterPlink_and_LogisticRegression.sh $BASE_DIR $gene $cohort $dp $cohort_folder;
        echo "STEP 10 START DP" $dp "COHORT" $cohort "GENE" $gene;
        bash $SCRIPT_FOLDER/Processing.step10.finalSelection.sh $BASE_DIR $gene $cohort $dp $core;
    done
done

echo "STEP 11 START"
bash $SCRIPT_FOLDER/Processing.step11.setup.seg.runs.merged.sh $BASE_DIR $gene_list $cohort
