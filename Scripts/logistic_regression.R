

args <- commandArgs(trailingOnly = TRUE)

raw_data <- args[1]
SETID_data <- args[2]
covar_file <- args[3]
phasing <- args[4]
gba <- args[5]
snv <- args[6]
type <- args[7]

covar <- read.table(covar_file, header = T, as.is =T)
covar_filtered <- subset(covar,  Age != "NA" & Sex != 0)

if(phasing == "notAdjust"){
	covar_filtered <- covar
}

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

result[result$var > 0, ]$var <- 1
result$PHENOTYPE <- result$PHENOTYPE - 1
result$PHENOTYPE <- as.factor(result$PHENOTYPE)
result$Sex <- as.factor(result$Sex)
result$Ethn <- as.factor(result$Ethn)

cont_table <- result[, c("PHENOTYPE", "var")]

fit <- glm(PHENOTYPE ~ var + Age + Sex, data = result, family = binomial)

if(phasing == "notAdjust"){
	fit <- glm(PHENOTYPE ~ var, data = result, family = binomial)
}

if(length(levels(result$Ethn)) > 1){
	fit <- glm(PHENOTYPE ~ var + Age + Sex + Ethn, data = result, family = binomial)

	if(phasing == "notAdjust"){
		fit <- glm(PHENOTYPE ~ var + Ethn, data = result, family = binomial)
	}
}
nrow(result)
table(cont_table)
prop.table(table(cont_table), 1)

carrier_freq <-  table(cont_table)
freq <- signif((carrier_freq[1,2] + carrier_freq[2,2])/sum(carrier_freq),3)
carrier_freq_case <- signif(carrier_freq[2,2]/(carrier_freq[2,1] + carrier_freq[2,2]),3)
carrier_freq_control <- signif(carrier_freq[1,2]/(carrier_freq[1,1] + carrier_freq[1,2]),3)
ncase <- carrier_freq[2,1] + carrier_freq[2,2]
ncontrol <- carrier_freq[1,1] + carrier_freq[1,2]
ntotal <- sum(carrier_freq)

ncase_carrier <- carrier_freq[2,2]
ncontrol_carrier <- carrier_freq[1,2]
percent_carrier_case <- carrier_freq_case * 100
percent_carrier_control <- carrier_freq_control * 100

ncase_carrier_percent <- paste0(ncase_carrier, " (", percent_carrier_case, ")")
ncontrol_carrier_percent <- paste0(ncontrol_carrier, " (", percent_carrier_control, ")")

CI <- signif(as.data.frame(confint.default(fit)),3)
var <- signif(as.data.frame(coef(summary(fit))),3)
var_list <- lapply(2:nrow(var), function(i){
    summary_stats <- cbind(var[i, 1, drop = FALSE], var[i, 2, drop = FALSE], paste0(" ",CI[i,1], "-", CI[i,2]) , var[i, 4, drop = FALSE])
    names(summary_stats) <- c("b", "StdErr", "95%_CI", "p")
    names(summary_stats) <- paste(row.names(summary_stats), names(summary_stats), sep = "_")
    return(summary_stats)
})

meta <- paste(phasing, gba, snv, type, sep = "_")
out <- cbind(phasing, gba, snv, type, meta, ntotal, ncase, ncontrol, 
	freq, carrier_freq_case, carrier_freq_control, ncase_carrier, ncontrol_carrier, 
	ncase_carrier_percent, ncontrol_carrier_percent, Reduce(cbind, var_list))

write.csv(out, file = gsub('.{6}$', paste0(".logit.", type, ".csv"), SETID_data), quote = F, row.names = F)
write.table(result, file = gsub('.{6}$', paste0(".logit.", type, ".sample.tab"), SETID_data), quote = F, row.names = F, sep = "\t")
