
packrat::init("~/runs/eyu8/library/SKAT")
library(SKAT)
library(MetaSKAT)

setwd("~/MIPVar/PD_All_MIP_genes_biallelic/MetaSKAT")
args <- commandArgs(trailingOnly = TRUE)

type_of_var <- args[1]

for(cohort in c("FC","NY","ISR")){
    File.Bed   = paste(type_of_var,cohort,"30x",paste0("PARK2_",cohort,"_30x",".bed"),sep="/")
    File.Bim   = paste(type_of_var,cohort,"30x",paste0("PARK2_",cohort,"_30x",".bim"),sep="/")
    File.Fam   = paste(type_of_var,cohort,"30x",paste0("PARK2_",cohort,"_30x",".fam"),sep="/")
    File.SetID = paste(type_of_var,cohort,"30x",paste0("PARK2_",cohort,"_30x",".SETID"),sep="/")
    File.Mat   = paste(type_of_var,cohort,"30x",paste0("PARK2_",cohort,"_30x",".MSSD"),sep="/")
    File.SetInfo  = paste(type_of_var,cohort,"30x",paste0("PARK2_",cohort,"_30x",".MInfo"),sep="/")
    File.cov = paste0("covar_",cohort,"_AAO.txt")
    FAM<-Read_Plink_FAM_Cov(File.Fam, File.cov, Is.binary =TRUE, cov_header=TRUE)
    y<-FAM$Phenotype
    Age<-FAM$Age
    Sex<-FAM$Sex
    Ethn<-FAM$Ethn
    N.Sample<-length(y)
    obj<-SKAT_Null_Model(y ~ Sex + Age + Ethn, out_type="D")

    re1<-Generate_Meta_Files(obj, File.Bed, File.Bim, File.SetID, File.Mat, File.SetInfo, N.Sample)

}

File.Mat.vec<-rep("",3)
File.Info.vec<-rep("",3)

n <- 1
for(cohort in c("FC","NY","ISR")){
    
    File.Mat <- paste(type_of_var,cohort,"30x",paste0("PARK2_",cohort,"_30x",".MSSD"),sep="/")
    File.Info <- paste(type_of_var,cohort,"30x",paste0("PARK2_",cohort,"_30x",".MInfo"),sep="/")
    File.Mat.vec[n]<-File.Mat
    File.Info.vec[n]<-File.Info
    n<-n+1
}

Cohort.Info<-Open_MSSD_File_2Read(File.Mat.vec, File.Info.vec)

out.skato.burden <- MetaSKAT_MSSD_ALL(Cohort.Info, method = "Burden")
out.skato<- MetaSKAT_MSSD_ALL(Cohort.Info, method = "optimal")
write.table(out.skato, file=paste(type_of_var,"MetaSKAT","PARK2_meta.skato",sep="/"), col.names = TRUE, row.names = FALSE)
write.table(out.skato.burden, file=paste(type_of_var,"MetaSKAT","PARK2_meta.burden",sep="/"), col.names = TRUE, row.names = FALSE)
