
args <- commandArgs(trailingOnly = TRUE)

work_dir = args[1]
covar_file = args[2]
var_file = args[3]
file_name = args[4]
setwd(work_dir)

covar <- read.table(covar_file, header = T)
var <- read.csv(var_file, header = T, sep=" ", check.names = FALSE)

var_per_sample <- apply(var[,-c(1:6)],1,sum, na.rm = TRUE)
var <- var[,1:6]
var <- merge(var,covar,by = "FID")
var <- var[,c("FID","SEX","PHENOTYPE","Age","Ethn")]

var$Carrier <- var_per_sample
var_het <- var[var$Carrier < 2,]
var_het$Carrier <- factor(var_het$Carrier)
var_het$PHENOTYPE <- var_het$PHENOTYPE - 1
var_het$PHENOTYPE <- factor(var_het$PHENOTYPE)
var_het <- var_het[var_het$SEX > 0,]
var_het$SEX <- var_het$SEX - 1
var_het$SEX <- factor(var_het$SEX)
var_het <- var_het[var_het$Age > 0,]
var_het$Ethn <- factor(var_het$Ethn)

if(length(levels(var_het$Ethn)) < 2){
    fit <- glm(PHENOTYPE ~ Carrier + SEX + Age, family = binomial, data = var_het)
} else {
    fit <- glm(PHENOTYPE ~ Carrier + SEX + Age + Ethn , family = binomial, data = var_het)
}
OR <- exp(coef(summary(fit))[c(1,2),1])

output <- cbind(OR,coef(summary(fit))[c(1,2),-1],exp(confint.default(fit)[c(1,2),]))

write.csv(output[2,,drop = FALSE], file = file_name, quote = FALSE, row.names = FALSE)
