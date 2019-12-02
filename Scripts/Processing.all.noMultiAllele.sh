#!/bin/bash

read BASE_DIR gene_list gene_bed output_name sample_list cohort_folder core <<< $@

SCRIPT_FOLDER=~/runs/eyu8/data/MIPVar/Scripts
echo "STEP 0 START"
#bash $SCRIPT_FOLDER/Processing.step00.FolderSetup.sh $BASE_DIR $gene_list 
echo "STEP 1 START"
#bash $SCRIPT_FOLDER/Processing.step01.getOnlyMySamples.noMultiAllele.sh $BASE_DIR $output_name $gene_bed $sample_list $core
echo "STEP 2 START"
#bash $SCRIPT_FOLDER/Processing.step02.maskCallsLower25GF.sh $output_name.vcf 
echo "STEP 3 START"
#bash $SCRIPT_FOLDER/Processing.step03.annotateVariants.sh $output_name"_GF25.vcf" $core $BASE_DIR

for dp in 15 30 50;
do 
    echo "STEP 4 START DP" $dp;
   # bash $SCRIPT_FOLDER/Processing.step04.removeLowQualVariants_GF_GQ_DP_MISS10.sh $output_name"_GF25_annotated.vcf" $dp $core;
    echo "STEP 5 START DP" $dp;
   # bash $SCRIPT_FOLDER/Processing.step05.flagBadSamplesAndCreateExclusionList.sh $output_name"_GF25_annotated_GQ30_DP"$dp"_MISS10_filtered.vcf";
    echo "STEP 6 START DP" $dp;
   # bash $SCRIPT_FOLDER/Processing.step06.excludeBadSamples.sh $output_name"_GF25_annotated_GQ30_DP"$dp"_MISS10_filtered.vcf" $output_name"_GF25_annotated_GQ30_DP"$dp"_MISS10_filtered.vcf.10PercentShitSamplesToExclude" $core;
    for cohort in FC NY ISR;
    do
        echo "STEP 7 START DP" $dp "COHORT" $cohort;
       # bash $SCRIPT_FOLDER/Processing.step07.selectByCohorts.sh $output_name"_GF25_annotated_GQ30_DP"$dp"_MISS10_filtered_cleaned.vcf" $cohort $dp $cohort_folder $core;
        for gene in $(cat $gene_list);
        do
            echo "STEP 8 START DP" $dp "COHORT" $cohort "GENE" $gene;
            #bash $SCRIPT_FOLDER/Processing.step08.selectByGene.sh $BASE_DIR $gene_bed $gene $cohort $dp $core;
            echo "STEP 9 START DP" $dp "COHORT" $cohort "GENE" $gene;
            bash $SCRIPT_FOLDER/Processing.step09.filterPlink_and_LogisticRegression.sh $BASE_DIR $gene $cohort $dp $cohort_folder;
            echo "STEP 10 START DP" $dp "COHORT" $cohort "GENE" $gene;
            bash $SCRIPT_FOLDER/Processing.step10.finalSelection.sh $BASE_DIR $gene $cohort $dp $core;
        done
    done
done

echo "STEP 11 START"
bash $SCRIPT_FOLDER/Processing.step11.setup.seg.runs.sh $BASE_DIR $gene_list
