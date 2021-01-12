library(data.table)

FC <- as.data.frame(fread("PARK2/FC/30x/AAO/PARK2_FC_30x_wCNV.linear.all.merged.tab"))
NY <- as.data.frame(fread("PARK2/NY/30x/AAO/PARK2_NY_30x_wCNV.linear.all.merged.tab"))
ISR <- as.data.frame(fread("PARK2/ISR/30x/AAO/PARK2_ISR_30x_wCNV.linear.all.merged.tab"))
meta_list <- as.data.frame(fread("PARK2/meta/30x/AAO/PARK2_meta_30x_wCNV.linear.all.merged.tab"))
meta_meta <- as.data.frame(fread("PARK2/meta/30x/AAO/METAL-PARK2-linear.tbl"))


meta <- merge(meta_list, meta_meta, by.x = "meta", by.y = "MarkerName")

names(meta)[13] <- "var_b"
names(meta)[15] <- "var_p"
meta <- meta[,-c(11,12,16:20)]
meta[,c("var_95%_CI")] <- paste0(signif(meta$var_b, 3), " (", signif(meta$var_b-2*meta$StdErr, 3), ", ", signif(meta$var_b+2*meta$StdErr, 3),")")


cohort_freq <- list(FC, NY, ISR, meta)
cohort_name <- c("FC", "NY", "ISR", "meta")


cohort_freq_RareAll <- lapply(cohort_freq, function(n){
	cohort_file <- n
	cohort_file_RareAll <- cohort_file[cohort_file$type == "RareAll", ]
	return(cohort_file_RareAll)
})



for(i in 1:4){

	cohort <- cohort_freq_RareAll[[i]]

	phasing <- cohort[grep("phasing", cohort$phasing),]
	unknown <- cohort[grep("unknown", cohort$phasing),]
	p <- list(phasing, unknown)

	phase <- lapply(p, function(j){

		wGBA_LRRK2 <- j[grep("wGBA_LRRK2", j$gba),]
		noGBA_LRRK2 <- j[grep("noGBA_LRRK2", j$gba),]
		adjust_GBA_LRRK2 <- j[grep("adjust_GBA_LRRK2", j$gba),]
		early_onset <- j[grep("early_onset", j$gba),]

		g <- list(wGBA_LRRK2, noGBA_LRRK2, adjust_GBA_LRRK2, early_onset)

		gba <- lapply(g, function(k){

			snv_order_list <- lapply(c("SNV", "CNV", "SNV_CNV", "Patho_SNV", "Patho_SNV_CNV", "No_Benign_SNV", "No_Benign_SNV_CNV"), function(i){
				which(k$snv == i)
				})

			snv_order <- Reduce(c, snv_order_list)

			return(k[snv_order, c("carrier_AAO_SD", "non_carrier_AAO_SD", "var_95%_CI", "var_p")])
		})

		return(Reduce(cbind, gba))
	})

	out <- Reduce(cbind, phase)

	write.table(out, file = paste("PARK2", cohort_name[i], "30x", "AAO", 
		paste0("PARK2_", cohort_name[i],"_30x_wCNV.results.AAO.all.final.table.csv"), sep = "/"), quote = F, row.names = F, sep = "\t")

}



