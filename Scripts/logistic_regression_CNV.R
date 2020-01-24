
args <- commandArgs(trailingOnly = TRUE)

work_dir = args[1]
covar_file = args[2]
var_file = args[3]
cnv_file = args[4]
file_name = args[5]

setwd(work_dir)
covar <- read.table(covar_file, header = T)
cnv <- read.csv(cnv_file, header = T, sep=",", check.names = FALSE)
var <- read.csv(var_file, header = T, sep=" ", check.names = FALSE)

var <- var[,1:6]
var <- merge(var,cnv,by = "FID", all.x = TRUE,)
var[is.na(var)] <- 0
var <- merge(var,covar,by = "FID")
var_het <- var[,c("FID","SEX","PHENOTYPE","Age","Ethn","PARK2_CNV")]

var_het$PARK2_CNV <- factor(var_het$PARK2_CNV)
var_het$PHENOTYPE <- var_het$PHENOTYPE - 1
var_het$PHENOTYPE <- factor(var_het$PHENOTYPE)
var_het <- var_het[var_het$SEX > 0,]
var_het$SEX <- var_het$SEX - 1
var_het$SEX <- factor(var_het$SEX)
var_het <- var_het[var_het$Age > 0,]
var_het$Ethn <- factor(var_het$Ethn)

if(length(levels(var_het$Ethn)) < 2){
    fit <- glm(PHENOTYPE ~ PARK2_CNV + SEX + Age, family = binomial, data = var_het)
} else {
    fit <- glm(PHENOTYPE ~ PARK2_CNV + SEX + Age + Ethn , family = binomial, data = var_het)
}
OR <- exp(coef(summary(fit))[c(1,2),1])

output <- cbind(OR,coef(summary(fit))[c(1,2),-1],exp(confint.default(fit)[c(1,2),]))

write.csv(output[2,,drop = FALSE], file = file_name, quote = FALSE, row.names = FALSE)
