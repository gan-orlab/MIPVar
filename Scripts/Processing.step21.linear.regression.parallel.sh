#!/bin/bash

module load gcc/7.3 r-bundle-bioconductor/3.9

risk=AAO_strict

for cohort in FC NY ISR
do
	for p in phasing unknown
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

				srun -c 5 --mem=20G -t 1:0:0 parallel 'Rscript ~/runs/eyu8/soft/MIPVar/Scripts/linear_regression.R \
					PARK2/{1}/30x/PARK2_{1}_30x_wCNV.raw \
					PARK2/{1}/30x/{7}/{2}/{3}/{4}/PARK2_{1}_30x_wCNV.SETID \
					PARK2/{1}/30x/{7}/{2}/{3}/{4}/covar_{1}_{5}.txt {2} {3} {4} {6} {7}' ::: $cohort ::: $p ::: \
					$g ::: $t ::: $het ::: RareCADD RareFunct RareLOF RareNS RareAll ::: $risk

				cat PARK2/$cohort/30x/$risk/$p/$g/$t/PARK2_${cohort}_30x_wCNV.linear.Rare*.table.tab | awk 'BEGIN{FS=OFS="\t"}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/$cohort/30x/$risk/$p/$g/$t/PARK2_${cohort}_30x_wCNV.linear.all.tab
				cat PARK2/$cohort/30x/$risk/$p/$g/$t/PARK2_${cohort}_30x_wCNV.linear.Rare*.preMeta.tab | awk 'BEGIN{FS=OFS="\t"}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/$cohort/30x/$risk/$p/$g/$t/PARK2_${cohort}_30x_wCNV.linear.all.preMeta.tab
			done
		done
	done

	cat PARK2/$cohort/30x/$risk/*/*/*/PARK2_${cohort}_30x_wCNV.linear.all.tab | awk 'BEGIN{FS=OFS="\t"}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/$cohort/30x/$risk/PARK2_${cohort}_30x_wCNV.linear.all.merged.tab
	cat PARK2/$cohort/30x/$risk/*/*/*/PARK2_${cohort}_30x_wCNV.linear.all.preMeta.tab | awk 'BEGIN{FS=OFS="\t"}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/$cohort/30x/$risk/PARK2_${cohort}_30x_wCNV.linear.all.merged.preMeta.tab

done

for p in phasing unknown
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
				Rscript ~/MIPVar/Scripts/add_metadata_linear_meta.R \
				PARK2/FC/30x/PARK2_FC_30x_wCNV.raw \
				PARK2/NY/30x/PARK2_NY_30x_wCNV.raw \
				PARK2/ISR/30x/PARK2_ISR_30x_wCNV.raw \
				PARK2/FC/30x/$risk/$p/$g/$t/PARK2_FC_30x_wCNV.SETID \
				PARK2/NY/30x/$risk/$p/$g/$t/PARK2_NY_30x_wCNV.SETID \
				PARK2/ISR/30x/$risk/$p/$g/$t/PARK2_ISR_30x_wCNV.SETID \
				PARK2/FC/30x/$risk/$p/$g/$t/covar_FC_$het.txt \
				PARK2/NY/30x/$risk/$p/$g/$t/covar_NY_$het.txt \
				PARK2/ISR/30x/$risk/$p/$g/$t/covar_ISR_$het.txt \
				$p $g $t $type \
				PARK2/meta/30x/$risk/$p/$g/$t/PARK2_meta_30x_wCNV.linear.$type.table.tab

			done

			cat PARK2/meta/30x/$risk/$p/$g/$t/PARK2_meta_30x_wCNV.linear.*.table.tab | \
			awk 'BEGIN{FS=OFS="\t"}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/meta/30x/$risk/$p/$g/$t/PARK2_meta_30x_wCNV.linear.all.tab

		done
	done
done

cat PARK2/meta/30x/$risk/*/*/*/PARK2_meta_30x_wCNV.linear.all.tab | \
awk 'BEGIN{FS=OFS="\t"}{if(NR==1){print;} if($4=="type"){next;} print;}' > PARK2/meta/30x/$risk/PARK2_meta_30x_wCNV.linear.all.merged.tab
