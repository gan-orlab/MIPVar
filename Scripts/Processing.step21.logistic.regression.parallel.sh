#!/bin/bash

module load gcc/7.3 r/3.5.2

risk=Risk_strict

for cohort in FC NY ISR
do
	for p in phasing unknown notAdjust
	do
		if [[ $p == "unknown" ]]; then
			het=het_strict_phasing
		else
			het=het_strict
		fi

		for g in wGBA_LRRK2 noGBA_LRRK2 early_onset adjust_GBA_LRRK2
		do
			for t in SNV CNV SNV_CNV Patho_SNV Patho_SNV_CNV No_Benign_SNV No_Benign_SNV_CNV
			do
				srun -c 5 --mem=20G -t 0:1:0 parallel 'Rscript ~/runs/eyu8/soft/MIPVar/Scripts/logistic_regression.R \
					PARK2/{1}/30x/PARK2_{1}_30x_wCNV.raw \
					PARK2/{1}/30x/{2}/{3}/{4}/{5}/PARK2_{1}_30x_wCNV.SETID \
					PARK2/{1}/30x/{2}/{3}/{4}/{5}/covar_{1}_{6}.txt {3} {4} {5} {7}' ::: $cohort ::: $risk ::: \
					$p ::: $g ::: $t ::: $het ::: RareCADD RareFunct RareLOF RareNS RareAll
				
				cat PARK2/$cohort/30x/$risk/$p/$g/$t/PARK2_${cohort}_30x_wCNV.logit.Rare*.csv | awk 'BEGIN{FS=OFS=","}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/$cohort/30x/$risk/$p/$g/$t/PARK2_${cohort}_30x_wCNV.logit.all.csv

			done
		done
	done

	cat PARK2/$cohort/30x/$risk/*/*/*/PARK2_${cohort}_30x_wCNV.logit.all.csv | awk 'BEGIN{FS=OFS=","}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/$cohort/30x/$risk/PARK2_${cohort}_30x_wCNV.logit.all.merged.csv

done
