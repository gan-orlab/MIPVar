#!/bin/bash

module load gcc/7.3 r/3.5.2

for p in notAdjust phasing unknown
do
	for g in wGBA_LRRK2 noGBA_LRRK2 early_onset adjust_GBA_LRRK2
	do 
		for type in SNV CNV SNV_CNV Patho_SNV Patho_SNV_CNV No_Benign_SNV No_Benign_SNV_CNV
		do
			
			if [[ $p == "unknown" ]]; then
				Rscript ~/runs/eyu8/soft/MIPVar/Scripts/MetaSKAT_PRKN.R "Risk" $p $g $type het_phasing
			else
				Rscript ~/runs/eyu8/soft/MIPVar/Scripts/MetaSKAT_PRKN.R "Risk" $p $g $type het
			fi

		done

	done

done
