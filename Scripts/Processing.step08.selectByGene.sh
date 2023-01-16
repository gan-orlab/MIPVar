#!/bin/bash

#I use variables, for readability
read BASE_DIR gene_bed gene cohort_name DP core <<< $@
if [[ -z $gene ]]; then echo "ERROR: gene (1st arg) not specified"; exit 42; fi
if [[ -z $DP || ! $DP -gt 0 ]]; then echo "ERROR: depth (2nd arg) not specified"; exit 42; fi
if [[ -z $cohort_name ]]; then echo "ERROR: cohort name (3rd arg) not specified"; exit 42; fi

REF=~/runs/go_lab/Reference/human_g1k_v37.fasta
ALL_BED=$gene_bed
GENE_BED=$BASE_DIR/$gene/$gene.wholegene.bed
#GENE_BED=$BASE_DIR/script.testing/genes/$gene/$gene.wholegene.bed
if [[ ! -s $GENE_BED ]]; then awk -F"\t" -v gene=$gene '$4==gene' $ALL_BED > $GENE_BED; fi

#vcf=$BASE_DIR/$cohort_name.DP$DP.all.genes.vcf
vcf=$BASE_DIR/$cohort_name.DP$DP.all.genes.vcf
#sample_list=$BASE_DIR/$cohort_name.samples.list
if [[ ! -s $vcf ]]; then echo "ERROR: input vcf empty or does not exist; name should be $vcf"; exit 42; fi
#if [[ ! -s $sample_list ]]; then echo "ERROR: sample list empty or does not exist; name should be $DP.$cohort_name.sample.list"; exit 42; fi
output=$BASE_DIR/$gene/$cohort_name/${DP}x/$gene.$cohort_name.DP$DP.vcf
#output=$BASE_DIR/script.testing/genes/$gene/$cohort_name/${DP}x/$gene.$cohort_name.DP$DP.vcf

#sed '/AC=0/d' -i $vcf
java -Xmx4g -jar /lustre03/project/6004655/COMMUN/soft/lib/java/GATK/GenomeAnalysisTK-3.8/dist/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V $vcf -o $output -L $GENE_BED -nt $core


#for gene in $(cat familial_pd_genes_except_GBA); do for cohort in FC NY ISR; do bash ../Scripts/Processing.step08.selectByGene.sh $gene $cohort 30; done; done
