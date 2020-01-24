

args <- commandArgs(trailingOnly = TRUE)

work_dir = args[1]
covar_file = args[2]
var_file_FC = args[3]
var_file_NY = args[4]
var_file_ISR = args[5]
cnv_file = args[6]

setwd(work_dir)
covar <- read.table(covar_file, header = T)
var_file <- list(var_file_FC,var_file_NY,var_file_ISR)
cnv <- read.csv(cnv_file, header = T, sep=",", check.names = FALSE)

var <- lapply(var_file,function(x){read.csv(x, header = T, sep=" ", check.names = FALSE)})
var_per_sample <- lapply(var,function(x){apply(x[,-c(1:6)],1,sum, na.rm = TRUE)})
var <- lapply(var,function(x){x[,1:6]})
var <- lapply(1:3,function(i){var[[i]]$COHORT <- i; return(var[[i]])})
var <- Reduce(rbind,lapply(1:3,function(i){var[[i]]$SNV <- var_per_sample[[i]]; return(var[[i]])}))

var <- merge(var,cnv,by = "FID", all.x = TRUE)
var[is.na(var)] <- 0

var_per_sample <- apply(var[,c("SNV","PARK2_CNV")],1,sum, na.rm = TRUE)
var$Carrier <- var_per_sample

var <- merge(var,covar,by = "FID")
var <- var[,c("FID","SEX","PHENOTYPE","Age","Ethn","Carrier","SNV","PARK2_CNV","COHORT")]

var_het <- var[var$Carrier < 2,]
var_het$Carrier <- factor(var_het$Carrier)
var_het$PARK2_CNV <- factor(var_het$PARK2_CNV)
var_het$SNV <- factor(var_het$SNV)
var_het$PHENOTYPE <- var_het$PHENOTYPE - 1
var_het$PHENOTYPE <- factor(var_het$PHENOTYPE)
var_het[var_het$SEX == 0,]$SEX <- NA
var_het$SEX <- var_het$SEX - 1
var_het$SEX <- factor(var_het$SEX)
var_het[var_het$Age == 0,]$Age <- NA
var_het$Ethn <- factor(var_het$Ethn)
var_het$COHORT <- factor(var_het$COHORT)

assoc <- function(dafr,file_name,x,coh){
    dafr[] <- lapply(dafr, function(x) if(is.factor(x)) factor(x) else x)
    if(length(levels(dafr$Ethn)) < 2){
        f <- as.formula(paste0("PHENOTYPE ~ ", x," + SEX + Age"))  
        fit <- glm(f, family = binomial, data = dafr)
    } else {
        f <- as.formula(paste0("PHENOTYPE ~ ", x," + SEX + Age + Ethn"))
        fit <- glm(f , family = binomial, data = dafr)
    }
    OR <- exp(coef(summary(fit))[c(1,2),1])
    output <- cbind(OR,coef(summary(fit))[c(1,2),-1],exp(confint.default(fit)[c(1,2),]))
    result <- as.data.frame(output[2,,drop = FALSE])
    result$Cohort <- coh
    result$Mut <- x
    return(result)
    #write.csv(output[2,,drop = FALSE], file = file_name, quote = FALSE, row.names = FALSE)
}


result <- lapply(c("SNV","PARK2_CNV","Carrier"),function(y){
                     coh <- c("FC","NY","ISR")
                     all_cohort <- lapply(1:3,function(x){assoc(var_het[var_het$COHORT == x,],fname,y,coh[x])})
                     all_cohort[[4]] <- assoc(var_het,fname,y,"merged")
                     return(Reduce(rbind,all_cohort))
})

write.csv(Reduce(rbind,result), file = "PRKN.freq.logistic.regression.csv", quote = FALSE, row.names = FALSE)
