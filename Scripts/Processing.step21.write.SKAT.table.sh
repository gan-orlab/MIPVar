#!/bin/bash

module load gcc/7.3 r-bundle-bioconductor/3.9

for p in phasing unknown notAdjust
do
	for g in wGBA_LRRK2 noGBA_LRRK2 early_onset adjust_GBA_LRRK2
	do
		for cohort in FC NY ISR
		do
			Rscript ~/runs/eyu8/soft/MIPVar/Scripts/write_table_SKAT.R $cohort "Risk" $p $g
		done

		Rscript ~/runs/eyu8/soft/MIPVar/Scripts/write_table_SKAT_meta.R "Risk" $p $g

	done
done
