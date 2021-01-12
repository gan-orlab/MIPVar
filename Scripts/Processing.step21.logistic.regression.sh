#!/bin/bash

module load gcc/7.3 r/3.5.2

for cohort in FC NY ISR
do
	for p in phasing unknown notAdjust
	do
		if [[ $p == "unknown" ]]; then
			het=het_phasing
		else
			het=het
		fi

		for g in wGBA_LRRK2 noGBA_LRRK2 early_onset adjust_GBA_LRRK2
		do
			for t in SNV CNV SNV_CNV Patho_SNV Patho_SNV_CNV No_Benign_SNV No_Benign_SNV_CNV
			do
				for type in RareCADD RareFunct RareLOF RareNS RareAll
				do
					
					Rscript ~/runs/eyu8/soft/MIPVar/Scripts/logistic_regression.R \
					PARK2/$cohort/30x/PARK2_${cohort}_30x_wCNV.raw \
					PARK2/$cohort/30x/Risk/$p/$g/$t/PARK2_${cohort}_30x_wCNV.SETID \
					PARK2/$cohort/30x/Risk/$p/$g/$t/covar_${cohort}_$het.txt $p $g $t $type | tee PARK2/$cohort/30x/Risk/$p/$g/$t/freq_logistic_$type.txt

				done
				
				cat PARK2/$cohort/30x/Risk/$p/$g/$t/PARK2_${cohort}_30x_wCNV.logit.Rare*.csv | awk 'BEGIN{FS=OFS=","}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/$cohort/30x/Risk/$p/$g/$t/PARK2_${cohort}_30x_wCNV.logit.all.csv

			done
		done
	done

	cat PARK2/$cohort/30x/Risk/*/*/*/PARK2_${cohort}_30x_wCNV.logit.all.csv | awk 'BEGIN{FS=OFS=","}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/$cohort/30x/Risk/PARK2_${cohort}_30x_wCNV.logit.all.merged.csv

done
