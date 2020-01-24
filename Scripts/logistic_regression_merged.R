
args <- commandArgs(trailingOnly = TRUE)

work_dir = args[1]
covar_file = args[2]
var_file_FC = args[3]
var_file_NY = args[4]
var_file_ISR = args[5]
file_name = args[6]

setwd(work_dir)
covar <- read.table(covar_file, header = T)
var_file <- list(var_file_FC,var_file_NY,var_file_ISR)
var <- lapply(var_file,function(x){read.csv(x, header = T, sep=" ", check.names = FALSE)})

var_per_sample <- lapply(var,function(x){apply(x[,-c(1:6)],1,sum, na.rm = TRUE)})

var <- lapply(var,function(x){x[,1:6]})
var <- Reduce(rbind,lapply(1:3,function(i){var[[i]]$Carrier <- var_per_sample[[i]]; return(var[[i]])}))

var <- merge(var,covar,by = "FID")
var <- var[,c("FID","SEX","PHENOTYPE","Age","Ethn","Carrier")]

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
