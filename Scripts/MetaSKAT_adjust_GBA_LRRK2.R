
wd <- getwd()

packrat::init("~/runs/eyu8/library/SKAT")
library(SKAT)
library(MetaSKAT)


setwd(wd)

args <- commandArgs(trailingOnly = TRUE)

#args <- c("Risk", "phasing", "wGBA_LRRK2", "CNV", "het")

risk <- args[1]
phasing <- args[2]
GBA_LRRK2 <- args[3]
type <- args[4]
covar_file <- args[5]

File.Meta.SKATO = paste("PARK2", "meta", "30x", risk, phasing, GBA_LRRK2, type, "PARK2_meta_30x_wCNV.results.skato",sep="/")
File.Meta.BURDEN = paste("PARK2", "meta", "30x", risk, phasing, GBA_LRRK2, type, "PARK2_meta_30x_wCNV.results.burden",sep="/")

File.Mat.vec<-rep("",3)
File.SetInfo.vec<-rep("",3)

i = 1
for(cohort in c("FC","NY","ISR")){
    File.Bed   = paste("PARK2", cohort, "30x", paste0("PARK2_",cohort,"_30x_wCNV",".bed"),sep="/")
    File.Bim   = paste("PARK2", cohort, "30x", paste0("PARK2_",cohort,"_30x_wCNV",".bim"),sep="/")
    File.Fam   = paste("PARK2", cohort, "30x", paste0("PARK2_",cohort,"_30x_wCNV",".fam"),sep="/")
    File.SetID = paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("PARK2_",cohort,"_30x_wCNV.SETID"),sep="/")
    File.SSD = paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("PARK2_",cohort,"_30x_wCNV.SSD"),sep="/")
    File.Info = paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("PARK2_",cohort,"_30x_wCNV.Info"),sep="/")
    File.Mat   = paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("PARK2_",cohort,"_30x_wCNV.MSSD"),sep="/")
    File.SetInfo  = paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("PARK2_",cohort,"_30x_wCNV.MInfo"),sep="/")
    File.cov = paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("covar_", cohort, "_", covar_file, ".txt"),sep="/")
    File.Results.SKATO = paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("PARK2_",cohort,"_30x_wCNV.results.skato"),sep="/")
    File.Results.BURDEN = paste("PARK2", cohort, "30x", risk, phasing, GBA_LRRK2, type, paste0("PARK2_",cohort,"_30x_wCNV.results.burden"),sep="/")

    Generate_SSD_SetID(File.Bed, File.Bim, File.Fam, File.SetID, File.SSD, File.Info)
    SSD.INFO<-Open_SSD(File.SSD, File.Info)

    FAM<-Read_Plink_FAM_Cov(File.Fam, File.cov, Is.binary =TRUE, cov_header=TRUE)
    y<-FAM$Phenotype
    Age<-FAM$Age
    Sex<-FAM$Sex.y
    Sex[Sex == 0] <- NA
    Ethn<-FAM$Ethn
    GBA_LRRK2_carrier<-FAM$GBA_LRRK2_carrier
    N.Sample<-length(y)
    obj<-SKAT_Null_Model(y ~ Age + Sex + Ethn + GBA_LRRK2_carrier, out_type="D")

    out.skato<-SKATBinary.SSD.All(SSD.INFO, obj, method="optimal.adj")
    out.skato.burden<-SKATBinary.SSD.All(SSD.INFO, obj, method="Burden")
    write.table(out.skato$results, file=File.Results.SKATO, col.names = TRUE, row.names = FALSE)
    write.table(out.skato.burden$results, file=File.Results.BURDEN, col.names = TRUE, row.names = FALSE)

    re1<-Generate_Meta_Files(obj, File.Bed, File.Bim, File.SetID, File.Mat, File.SetInfo, N.Sample)
    
    File.Mat.vec[i] <- File.Mat
    File.SetInfo.vec[i] <- File.SetInfo

    i <- i + 1
}


Cohort.Info <- Open_MSSD_File_2Read(File.Mat.vec, File.SetInfo.vec)

out.skato.burden <- MetaSKAT_MSSD_ALL(Cohort.Info, method = "Burden")
out.skato<- MetaSKAT_MSSD_ALL(Cohort.Info, method = "optimal")
write.table(out.skato, file= File.Meta.SKATO, col.names = TRUE, row.names = FALSE)
write.table(out.skato.burden, file= File.Meta.BURDEN, col.names = TRUE, row.names = FALSE)
