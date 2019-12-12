#!/bin/bash

module load intel/2018.3
module load vcftools

read BASE_DIR gene cohort_name DP cohort_folder<<< $@
if [[ -z $gene ]]; then echo "ERROR: gene (1st arg) not specified"; exit 42; fi
if [[ -z $cohort_name ]]; then echo "ERROR: cohort_name (2nd arg) not specified"; exit 42; fi
if [[ -z $DP ]]; then echo "ERROR: depth (3rd arg) not specified"; exit 42; fi


ANALYSIS_DIR=$BASE_DIR/$gene/$cohort_name/${DP}x/analysis


vcf=$BASE_DIR/$gene/$cohort_name/${DP}x/$gene.$cohort_name.DP$DP.vcf
sex=$cohort_folder/sex_$cohort_name.txt
pheno=$cohort_folder/pheno_$cohort_name.txt
covar=$cohort_folder/covar_$cohort_name.txt
if [[ ! -s $vcf ]]; then echo "ERROR: vcf file empty or does not exist; name should be $vcf"; exit 42; fi
if [[ ! -s $sex ]]; then echo "ERROR: sex file empty or does not exist; name should be $sex"; exit 42; fi
if [[ ! -s $pheno ]]; then echo "ERROR: pheno file empty or does not exist; name should be $pheno"; exit 42; fi
if [[ ! -s $covar ]]; then echo "ERROR: covar file empty or does not exist; name should be $covar"; exit 42; fi

#name=${gene}_${cohort_name}_DP$DP
name=$BASE_DIR/$gene/$cohort_name/${DP}x/${gene}_${cohort_name}_DP$DP

#vcf>tfile format
#vcftools --vcf $vcf --plink-tped --out $name 

#update sex and pheno
plink --vcf $vcf --keep-allele-order --update-sex $sex --make-bed --allow-no-sex --out $name
#plink --tfile $name --update-sex $sex --make-bed --allow-no-sex --out $name 
plink --bfile $name --pheno $pheno --make-bed --allow-no-sex --out $name  

#filtration steps

plink --bfile $name --missing --allow-no-sex --out ${name}.missingindv 
awk 'NR>1 && $5>0.1 {print $2}' ${name}.missingindv.lmiss > ${name}.geno10.snpstoremove
plink --bfile $name --exclude ${name}.geno10.snpstoremove --make-bed --allow-no-sex --out ${name}_geno10 

awk 'NR>1 && $6 >0.1{print $1,$2}' ${name}.missingindv.imiss > ${name}.geno10.indvtoremove
plink --bfile ${name}_geno10 --remove ${name}.geno10.indvtoremove --make-bed --allow-no-sex --out ${name}_geno10_ind10 

plink --bfile ${name}_geno10_ind10 --hardy --allow-no-sex --out ${name}_geno10_ind10_hwe 
awk 'NR>1 && $9<0.001 {print $2}' ${name}_geno10_ind10_hwe.hwe > ${name}_geno10_ind10_hwe.snpstoremove
plink --bfile ${name}_geno10_ind10 --exclude ${name}_geno10_ind10_hwe.snpstoremove --make-bed --allow-no-sex --out ${name}_geno10_ind10_hwe 


plink --bfile ${name}_geno10_ind10_hwe --test-missing --allow-no-sex --out ${name}_geno10_ind10_hwe_testmissing 

#Bonferonni cut off 0.05/#of SNPs, see how many get removed
cat ${name}_geno10_ind10_hwe_testmissing.missing | tail -n +2 | awk -v x="$(wc -l ${name}_geno10_ind10_hwe.bim)" '{ if ($5<0.05/x) {print $2}}'  > ${name}_geno10_ind10_hwe_testmissing.snpstoremove
#awk 'NR>1 && $5<0.0125 {print $2}' ${name}_geno10_ind10_hwe_testmissing.missing > ${name}_geno10_ind10_hwe_testmissing.snpstoremove

plink --bfile ${name}_geno10_ind10_hwe --exclude ${name}_geno10_ind10_hwe_testmissing.snpstoremove --make-bed --allow-no-sex --out ${name}_geno10_ind10_hwe_testmiss 

plink --bfile ${name}_geno10_ind10_hwe_testmiss --logistic hide-covar --covar $covar --covar-name Sex,Age --ci 0.95 --out $name 
plink --bfile ${name}_geno10_ind10_hwe_testmiss --assoc fisher --out $name

cp ${name}_geno10_ind10_hwe_testmiss* $ANALYSIS_DIR/

#create file w samples to include, from fam file (col 1)
#cut -f1 ${name}_geno10_ind10_hwe_testmiss.fam > $gene.$cohort_name.DP$DP.final.samples
cut -d ' ' -f1 ${name}_geno10_ind10_hwe_testmiss.fam > ${name}.final.samples
#create file w snps to include, from bim file (col 2)
#cut -f2 ${name}_geno10_ind10_hwe_testmiss.bim > $gene.$cohort_name.DP$DP.final.intervals
#cut -f2 ${name}_geno10_ind10_hwe_testmiss.bim > ${name}.final.intervals

plink --bfile ${name}_geno10_ind10_hwe_testmiss --recode vcf --out ${name}_geno10_ind10_hwe_testmiss

#paste <(cut -f1-4,6,7,9,10,12 ${name}.assoc.logistic) <(cut -f5-6  ${name}.assoc.fisher) > $ANALYSIS_DIR/$gene.$cohort_name.DP$DP.stats
paste ${name}.assoc.logistic ${name}.assoc.fisher | sed 's/ \+/\t/g' | awk '{print $1,$2,$3,$4,$19,$6,$7,$9,$10,$12,$17,$18}' OFS="\t" > $ANALYSIS_DIR/$gene.$cohort_name.DP$DP.stats


#sed 's/ \+/\t/g' ${name}.assoc.logistic
#sed 's/ \+/\t/g' ${name}.assoc.fisher
#paste ${name}.assoc.logistic ${name}.assoc.fisher | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$4,$19,$6,$7,$9,$10,$12,$17,$18}' > $ANALYSIS_DIR/$gene.$cohort_name.DP$DP.stats
