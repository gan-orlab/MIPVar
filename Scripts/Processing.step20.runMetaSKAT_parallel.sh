#!/bin/bash

module load gcc/7.3 r/3.5.2

srun -c 10 --mem=40G -t 1:0:0 parallel 'Rscript ~/runs/eyu8/soft/MIPVar/Scripts/MetaSKAT_PRKN.R Risk_strict unknown {1} {2} het_phasing' ::: \
wGBA_LRRK2 noGBA_LRRK2 early_onset adjust_GBA_LRRK2 ::: SNV CNV SNV_CNV Patho_SNV Patho_SNV_CNV No_Benign_SNV No_Benign_SNV_CNV

srun -c 10 --mem=40G -t 1:0:0 parallel 'Rscript ~/runs/eyu8/soft/MIPVar/Scripts/MetaSKAT_PRKN.R Risk_strict {1} {2} {3} het' ::: \
phasing notAdjust ::: wGBA_LRRK2 noGBA_LRRK2 early_onset adjust_GBA_LRRK2 ::: SNV CNV SNV_CNV Patho_SNV Patho_SNV_CNV No_Benign_SNV No_Benign_SNV_CNV
