#!/bin/bash

for cohort in NY; do
	for DP in 30x 50x; do
		cat $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareAll.txt | awk -F "\t" '{ if (NR==1 || $19 ~ /stop/ ||$19 ~ /nonsyn/ || $19 ~ /frame/ || ($19 ~ /intronic_splicing/ && $19 ~ /[+-][1-2]/)|| $22 != "") print $0}' > $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareFunct.txt; #To get functional vars only (NS+SPL[+-1,2]+ENCODE+LOF
		cat $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareAll.txt | awk -F "\t" '{ if (NR==1 ||$19 ~ /nonsyn/ ) print $0}' > $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareNS.txt; #To get NS vars 
		cat $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareAll.txt | awk -F "\t" '{ if (NR==1 || $19 ~ /stop/ || $19 ~ /frame/ || ($19 ~ /intronic_splicing/ && $19 ~ /[+-][1-2]/) ) print $0}' > $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareLOF.txt; #To get LOF vars (stopgain, frameshift and splice)
		cat $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareAll.txt | awk -F "\t" '{ if (NR==1 || $22 != "") print $0}' > $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareEncode.txt; #To get Encode vars
		cat $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareAll.txt | awk -F "\t" '{ if (NR==1 || $15 >= 12.37) print $0}' > $cohort/$DP/PD.${cohort}.${DP}.final.output.clean.OnlyRareCADD.txt; #To get CADD vars 
	done;
done
