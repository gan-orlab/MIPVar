#!/usr/bin/env Rscript
#packrat::init("/home/vrudakov/soft/lib/R-packrat/SKAT")
packrat::init("~/soft/lib/R-packrat/SKAT")
library(SKAT)
### Parse input variables
require(methods)
require(Xmisc)
parser <- ArgumentParser$new()
parser$add_argument('--dir', type='character', help='working directory aka your SKAT_Analysis folder')
parser$add_argument('--prefix', type='character', help='prefix of files')
parser$add_argument('--covar',  type='character', help='covariate file')
#### Setup script doc and help messages
parser$add_usage('R.SKAT [options]')
parser$add_description('setup and run R SKAT for one gene one cohort one depth')
parser$add_argument('--h',type='logical', action='store_true', help='Print the help page')
parser$add_argument('--help',type='logical', action='store_true', help='Print the help page')
parser$helpme()

wd=dir


setwd(wd)
File.Bed   = paste0(prefix,".bed")
File.Bim   = paste0(prefix,".bim")
File.Fam   = paste0(prefix,".fam")
File.SetID = paste0(prefix,".SETID")
File.SSD   = paste0(prefix,".SSD")
File.Info  = paste0(prefix,".info")
File.Cov   = covar
File.Results.SKATO  = paste0(prefix, ".results.skato")
File.Results.BURDEN = paste0(prefix, ".results.burden")

Generate_SSD_SetID(File.Bed, File.Bim, File.Fam, File.SetID, File.SSD, File.Info)

SSD.INFO<-Open_SSD(File.SSD, File.Info)
SSD.INFO$nSample
SSD.INFO$nSets

FAM<-Read_Plink_FAM_Cov(File.Fam, File.Cov, Is.binary = TRUE,  cov_header=TRUE)
y<-FAM$Phenotype
Age<-FAM$Age
Sex<-FAM$Sex.y
Ethn<-FAM$Ethn
out_type <- "D"
 
obj<-SKAT_Null_Model(y ~ Sex + Age + Ethn, out_type=out_type)

out.skato<-SKATBinary.SSD.All(SSD.INFO, obj, method="optimal.adj")
out.skato.burden<-SKATBinary.SSD.All(SSD.INFO, obj, method="Burden")
write.table(out.skato$results, file=File.Results.SKATO, col.names = TRUE, row.names = FALSE)
write.table(out.skato.burden$results, file=File.Results.BURDEN, col.names = TRUE, row.names = FALSE)
