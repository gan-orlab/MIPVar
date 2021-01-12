library(data.table)

FC <- as.data.frame(fread("PARK2/FC/30x/Risk/PARK2_FC_30x_wCNV.logit.all.merged.preMeta.csv"))
NY <- as.data.frame(fread("PARK2/NY/30x/Risk/PARK2_NY_30x_wCNV.logit.all.merged.preMeta.csv"))
ISR <- as.data.frame(fread("PARK2/ISR/30x/Risk/PARK2_ISR_30x_wCNV.logit.all.merged.preMeta.csv"))
meta <- as.data.frame(fread("PARK2/meta/30x/Risk/METAL-PARK2-logit.tbl"))


FC_SKAT <- as.data.frame(fread("PARK2/FC/30x/Risk/PARK2_FC_30x_wCNV.results.SKAT.all.csv"))
NY_SKAT <- as.data.frame(fread("PARK2/NY/30x/Risk/PARK2_NY_30x_wCNV.results.SKAT.all.csv"))
ISR_SKAT <- as.data.frame(fread("PARK2/ISR/30x/Risk/PARK2_ISR_30x_wCNV.results.SKAT.all.csv"))
meta_SKAT <- as.data.frame(fread("PARK2/meta/30x/Risk/PARK2_meta_30x_wCNV.results.SKAT.all.csv"))

cohort_SKAT <- list(FC_SKAT, NY_SKAT, ISR_SKAT, meta_SKAT)
cohort_freq <- list(FC, NY, ISR)
cohort_name <- c("FC", "NY", "ISR", "meta")

meta <- meta[,-c(2,3)]
meta <- meta[grep("RareAll", meta$MarkerName), ]
meta$MarkerName <- paste(meta$MarkerName, "SKAT", sep ="_")


cohort_SKAT_RareAll <- lapply(cohort_SKAT, function(n){
	SKAT_file <- n
	SKAT_file_RareAll <- SKAT_file[, grep("RareAll_SKAT", names(SKAT_file))]
	return(SKAT_file_RareAll)
})

cohort_freq_RareAll <- lapply(cohort_freq, function(n){
	cohort_file <- n
	cohort_file_RareAll <- cohort_file[cohort_file$type == "RareAll", ]
	cohort_file_RareAll$meta <- paste(cohort_file_RareAll$meta, "SKAT", sep ="_")
	return(cohort_file_RareAll)
})


meta_freq_list <- lapply(1:nrow(meta), function(i){
	cohort_snv_list <- lapply(1:3, function(j){
		cohort_freq_RareAll[[j]][cohort_freq_RareAll[[j]]$meta == meta$MarkerName[i],]
		})
	cohort_snv <- Reduce(rbind, cohort_snv_list)

	ntotal <- sum(cohort_snv$ntotal)
	ncase <- sum(cohort_snv$ncase)
	ncontrol <- sum(cohort_snv$ncontrol)
	freq <- sum(cohort_snv$ntotal * cohort_snv$freq)/ntotal
	carrier_freq_case <- sum(cohort_snv$ncase * cohort_snv$carrier_freq_case)/ncase
	carrier_freq_control <- sum(cohort_snv$ncontrol * cohort_snv$carrier_freq_control)/ncontrol


	ncase_carrier <- sum(cohort_snv$ncase_carrier)
	ncontrol_carrier <- sum(cohort_snv$ncontrol_carrier)

	percent_carrier_case <- signif(carrier_freq_case * 100, 3)
	percent_carrier_control <- signif(carrier_freq_control * 100, 3)

	ncase_carrier_percent <- paste0(ncase_carrier, " (", percent_carrier_case, ")")
	ncontrol_carrier_percent <- paste0(ncontrol_carrier, " (", percent_carrier_control, ")")

	MarkerName <- meta[i, c(1)]

	return(cbind(MarkerName, ntotal, ncase, ncontrol, 
	freq, carrier_freq_case, carrier_freq_control, ncase_carrier_percent, ncontrol_carrier_percent, meta[i, 2:9]))
})

meta_freq <- Reduce(rbind,meta_freq_list)

names(meta_freq)[1] <- "meta"
meta_freq$meta <- as.character(meta_freq$meta)
meta_freq$ncase_carrier_percent <- as.character(meta_freq$ncase_carrier_percent)
meta_freq$ncontrol_carrier_percent <- as.character(meta_freq$ncontrol_carrier_percent)

cohort_freq_RareAll[[4]] <- meta_freq

write.csv(meta_freq, file = "PARK2/meta/30x/Risk/PARK2_meta_30x_wCNV.logit.all.merged.csv", quote = F, row.names = F)

for(cohort in 1:4){
	SKAT_file_RareAll <- cohort_SKAT_RareAll[[cohort]]
	cohort_file_RareAll <- cohort_freq_RareAll[[cohort]]

	cohort_result_list <- lapply(1:length(names(SKAT_file_RareAll)), function(n){
			SKAT_col <- signif(SKAT_file_RareAll[,n], 3)
			test_name <- names(SKAT_file_RareAll)[n]
			test_name_split <- strsplit(test_name, "RareAll")[[1]]
			test_name_pattern <- paste(test_name_split, collapse = ".*")

			cohort_file_RareAll_test_name <- cohort_file_RareAll[grep(test_name_pattern,cohort_file_RareAll$meta),]
			cohort_file_RareAll_test_name_trimmed_front <- unlist(strsplit(cohort_file_RareAll_test_name$meta, test_name_split[1]))[seq(2,14,2)]
			cohort_file_RareAll_test_name$snv <- unlist(strsplit(cohort_file_RareAll_test_name_trimmed_front, "_RareAll_SKAT"))

			snv_order_list <- lapply(c("SNV", "CNV", "SNV_CNV", "Patho_SNV", "Patho_SNV_CNV", "No_Benign_SNV", "No_Benign_SNV_CNV"), function(i){
				which(cohort_file_RareAll_test_name$snv == i)
				})

			snv_order <- Reduce(c, snv_order_list)

			ncase_carrier_percent <- cohort_file_RareAll_test_name[snv_order,]$ncase_carrier_percent
			ncontrol_carrier_percent <- cohort_file_RareAll_test_name[snv_order,]$ncontrol_carrier_percent
			return(cbind(ncase_carrier_percent, ncontrol_carrier_percent, SKAT_col))


		})

	cohort_result <- Reduce(cbind, cohort_result_list)

	write.csv(cohort_result, file = paste("PARK2", cohort_name[cohort], "30x", "Risk", 
		paste0("PARK2_", cohort_name[cohort],"_30x_wCNV.results.SKAT.all.final.table.csv"), sep = "/"), quote = F, row.names = F)

}

