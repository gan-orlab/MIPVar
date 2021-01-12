#module load gcc/7.3 r-bundle-bioconductor/3.9


library(data.table)

args <- commandArgs(trailingOnly = T)

cohort <- args[1]
risk <- args[2]
phasing <- args[3]
GBA_LRRK2 <- args[4]

SKAT_list <- lapply(c("SNV", "CNV", "SNV_CNV", "Patho_SNV", "Patho_SNV_CNV", "No_Benign_SNV", "No_Benign_SNV_CNV"), function(type){

	skat_result <- as.data.frame(fread(paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("PARK2_",cohort,"_30x_wCNV.results.skato"),sep="/")))

	burden_result <- as.data.frame(fread(paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("PARK2_",cohort,"_30x_wCNV.results.burden"),sep="/")))

	combined_result <- data.frame()

	for(set in c("RareCADD", "RareFunct", "RareLOF", "RareNS", "RareAll")){

		combined_result[1,paste(phasing, GBA_LRRK2, set, "SKAT", sep ="_")] <- NA
		combined_result[1,paste(phasing, GBA_LRRK2, set, "burden", sep ="_")] <- NA

		if(any(skat_result$SetID == paste0("PARK2_30x_", set) & burden_result$SetID == paste0("PARK2_30x_", set))){

			combined_result[1,paste(phasing, GBA_LRRK2, set, "SKAT", sep ="_")] <- skat_result[skat_result$SetID == paste0("PARK2_30x_", set), "P.value"]
			combined_result[1,paste(phasing, GBA_LRRK2, set, "burden", sep ="_")] <- burden_result[burden_result$SetID == paste0("PARK2_30x_", set), "P.value"]

		}

	}

	return(combined_result)

})

all_result <- Reduce(rbind, SKAT_list)

write.csv(all_result, file = paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, paste0("PARK2_",cohort,"_30x_wCNV.results.merged.csv"), sep="/"), quote = F, row.names = F)


