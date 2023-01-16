for r in Risk_strict
do
	for cohort in FC NY ISR
	do 
		for p in phasing unknown notAdjust
		do
			if [[ $p == "unknown" ]]; then
				covarfile=covar_${cohort}_het_strict_phasing.txt
			else
				covarfile=covar_${cohort}_het_strict.txt
			fi

			for g in wGBA_LRRK2 noGBA_LRRK2 early_onset adjust_GBA_LRRK2
			do 
				grep -v PRKN PARK2/$cohort/30x/PARK2_${cohort}_30x_wCNV.SETID | sed "s/$cohort//g" > PARK2/$cohort/30x/$r/$p/$g/SNV/PARK2_${cohort}_30x_wCNV.SETID
				grep PRKN PARK2/$cohort/30x/PARK2_${cohort}_30x_wCNV.SETID | sed "s/$cohort//g" > PARK2/$cohort/30x/$r/$p/$g/CNV/PARK2_${cohort}_30x_wCNV.SETID
				sed "s/$cohort//g" PARK2/$cohort/30x/PARK2_${cohort}_30x_wCNV.SETID > PARK2/$cohort/30x/$r/$p/$g/SNV_CNV/PARK2_${cohort}_30x_wCNV.SETID
				grep -v PRKN PARK2/$cohort/30x/PARK2_${cohort}_30x_wCNV.SETID | grep -f patho.txt | sed "s/$cohort//g" > PARK2/$cohort/30x/$r/$p/$g/Patho_SNV/PARK2_${cohort}_30x_wCNV.SETID
				grep -f patho.txt PARK2/$cohort/30x/PARK2_${cohort}_30x_wCNV.SETID | sed "s/$cohort//g" > PARK2/$cohort/30x/$r/$p/$g/Patho_SNV_CNV/PARK2_${cohort}_30x_wCNV.SETID
				grep -v PRKN PARK2/$cohort/30x/PARK2_${cohort}_30x_wCNV.SETID | grep -f no_benign.txt | sed "s/$cohort//g" > PARK2/$cohort/30x/$r/$p/$g/No_Benign_SNV/PARK2_${cohort}_30x_wCNV.SETID
				grep -f no_benign.txt PARK2/$cohort/30x/PARK2_${cohort}_30x_wCNV.SETID | sed "s/$cohort//g" > PARK2/$cohort/30x/$r/$p/$g/No_Benign_SNV_CNV/PARK2_${cohort}_30x_wCNV.SETID

				for type in SNV CNV SNV_CNV Patho_SNV Patho_SNV_CNV No_Benign_SNV No_Benign_SNV_CNV
				do
					if [[ $g == "wGBA_LRRK2" ]]; then
						cp $covarfile PARK2/$cohort/30x/$r/$p/wGBA_LRRK2/$type/
					elif [[ $g == "noGBA_LRRK2" ]]; then
						grep -v -f GBA_LRRK2_G2019S_carriers.txt $covarfile > PARK2/$cohort/30x/$r/$p/noGBA_LRRK2/$type/$covarfile
					elif [[ $g == "adjust_GBA_LRRK2" ]]; then

						awk 'BEGIN{FS=OFS="\t"}{if(NR==FNR){carrier[$1]=1;next} $7=0; if(FNR==1){$7="GBA_LRRK2_carrier";} if(carrier[$1]==1){$7=1;} print}' GBA_LRRK2_G2019S_carriers.txt $covarfile > PARK2/$cohort/30x/$r/$p/adjust_GBA_LRRK2/$type/$covarfile

					else
						awk 'BEGIN{FS=OFS="\t"}{if($3==2 && $5 > 50){next;} print; }' $covarfile | grep -v -f GBA_LRRK2_G2019S_carriers.txt > PARK2/$cohort/30x/$r/$p/early_onset/$type/$covarfile
					fi

				done

			done

		done

	done
done
