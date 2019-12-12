#!/bin/bash

read BASE_DIR gene_list gene_bed output_name sample_list core <<< $@

SCRIPT_FOLDER=~/runs/eyu8/data/MIPVar/Scripts
echo "STEP 1 START"
bash $SCRIPT_FOLDER/Processing.step01.getOnlyMySamples.noMultiAllele.sh $BASE_DIR $output_name $gene_bed $sample_list $core
echo "STEP 3 START"
bash $SCRIPT_FOLDER/Processing.step03.annotateVariants.sh $output_name".vcf" $core $BASE_DIR

echo "STEP 11 START"

plink --vcf $output_name"_annotated.vcf" --make-bed --out $output_name ;
awk '{print "1 "$2" "$3" "$4" "$5" 2"}' $output_name.fam > $output_name.PED;


bash $SCRIPT_FOLDER/Processing.step11.setup.seg.runs.MLPA.sh $BASE_DIR $gene_list $output_name
