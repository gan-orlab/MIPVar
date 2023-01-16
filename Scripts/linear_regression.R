library(readr)

args <- commandArgs(trailingOnly = TRUE)

raw_data <- args[1]
SETID_data <- args[2]
covar_file <- args[3]
phasing <- args[4]
gba <- args[5]
snv <- args[6]
type <- args[7]

covar <- read.table(covar_file, header = T, as.is =T)
covar_filtered <- subset(covar,  Age != "NA" & Sex != 0 & Status == 2)

cohort_raw <- read.table(raw_data, header = T, as.is =T)

cohort_SETID <- read.table(SETID_data, as.is = T)
colnames(cohort_SETID) <- c("group","snp")


cohort_data <-cohort_raw[,-c(1:6)]

cohort_stats <- cohort_raw[,colnames(cohort_raw) %in% c("FID", "PHENOTYPE"), drop = F]

if(any(cohort_SETID$group == paste0("PARK2_30x_", type))){
	cohort_var <- cohort_SETID[cohort_SETID$group == paste0("PARK2_30x_", type),"snp"]
	cohort_snp <- cohort_var

	cnv_flag <- F
	if(length(grep("PRKN",cohort_var))){
		cnv <- grep("PRKN",cohort_var)
		cohort_cnv <- cohort_var[cnv]
		cohort_snp <- cohort_var[-grep("PRKN",cohort_var)]
		cnv_flag <- T
	}

	if(length(cohort_snp) > 0){
		snp_split <- strsplit(cohort_snp,":")
		snp_per_group.list <- lapply(snp_split,function(i){
			if(length(i)>3){
				return(i[2]);
			}else{
				return(i[1])}
		})
		snp_per_group <- Reduce(c,snp_per_group.list)
		if(cnv_flag){
			snp_per_group_pattern <- paste(paste(snp_per_group, collapse = "|"), paste(cohort_cnv, collapse = "|"), sep = "|")
		}
		else{
			snp_per_group_pattern <- paste(snp_per_group, collapse = "|")
		}
	} else {
		snp_per_group_pattern <- paste(cohort_cnv, collapse = "|")
	}



	cohort_snp_per_group <- cohort_data[,grep(colnames(cohort_data), pattern = snp_per_group_pattern), drop = F]

	cohort_stats$var <- apply(cohort_snp_per_group, 1, function(x){
		if(any(x > 0, na.rm = T)){
			return(sum(x, na.rm = T))
		}
		return(0)
	})

} else{

	cohort_stats$var <- 0

}

result <- merge(covar_filtered, cohort_stats, by = "FID")


if(any(result$var > 0)){
	result[result$var > 0, ]$var <- 1
}


result$Sex <- as.factor(result$Sex)
result$Ethn <- as.factor(result$Ethn)

fit <- lm(Age ~ var + Sex, data = result)

if(length(levels(result$Ethn)) > 1){
	fit <- lm(Age ~ var + Sex + Ethn, data = result)

	if(gba == "adjust_GBA_LRRK2"){
		fit <- lm(Age ~ var + Sex + Ethn + GBA_LRRK2_carrier, data = result)
	}
}

carrier_AAO <- signif(mean(subset(result, var == 1)$Age), 4)
carrier_SD <- signif(sd(subset(result, var == 1)$Age), 4)
non_carrier_AAO <- signif(mean(subset(result, var == 0)$Age), 4)
non_carrier_SD <- signif(sd(subset(result, var == 0)$Age), 4)
ntotal <- nrow(result)
ncarrier <- nrow(subset(result, var == 1))
n_noncarrier <- nrow(subset(result, var == 0))

CI <- signif(as.data.frame(confint.default(fit)),3)
var <- signif(as.data.frame(coef(summary(fit))),3)
var_list <- lapply(2:nrow(var), function(i){
    summary_stats <- cbind(var[i, 1, drop = FALSE], var[i, 2, drop = FALSE], 
    	paste0(var[i, 1, drop = FALSE], " (", CI[i,1], ",", CI[i,2], ")") , var[i, 4, drop = FALSE])
    names(summary_stats) <- c("b", "StdErr", "95%_CI", "p")
    names(summary_stats) <- paste(row.names(summary_stats), names(summary_stats), sep = "_")
    return(summary_stats)
})

meta <- paste(phasing, gba, snv, type, sep = "_")
carrier_AAO_SD <- paste0(carrier_AAO," (", carrier_SD, ")")
non_carrier_AAO_SD <- paste0(non_carrier_AAO," (", non_carrier_SD, ")")
out <- cbind(phasing, gba, snv, type, meta, ntotal, ncarrier, n_noncarrier, 
	carrier_AAO_SD, non_carrier_AAO_SD, Reduce(cbind, var_list))

write_excel_csv(out[,c(1:14)], path = gsub('.{6}$', paste0(".linear.", type, ".table.tab"), SETID_data), delim = "\t")
write_excel_csv(out[,c(1:6,11:12,14)], path = gsub('.{6}$', paste0(".linear.", type, ".preMeta.tab"), SETID_data), delim = "\t")
#write.table(result, file = gsub('.{6}$', paste0(".linear.", type, ".sample.tab"), SETID_data), quote = F, row.names = F, sep = "\t")
