
library(data.table)

args <- commandArgs(trailingOnly = TRUE)

#args <- c("PARK2/NY/30x/PARK2_NY_30x.ped","PARK2/NY/30x/PARK2_NY_30x.map", "ExomeDepth_CNV.txt", "PARK2/NY/30x/PARK2_NY_30x.SETID")

ped <- as.data.frame(fread(args[1],  header = F))

map <- as.data.frame(fread(args[2],  header = F))

cnv_file <- as.data.frame(fread(args[3]))

SETID_file <- as.data.frame(fread(args[4], header = F))


names(map) <- c("chr", "SNP", "morgan", "pos")

prkn_cnv_uniq <- sort(unique(cnv_file$Final_CNV[grep("PRKN", cnv_file$Final_CNV)]))

prkn_cnv_uniq_dafr <- as.data.frame(cbind(6,prkn_cnv_uniq,0,1:length(prkn_cnv_uniq)))

SETID_All <- sort(unique(SETID_file$V1[grep("All", SETID_file$V1)]))
SETID <- c(SETID_All, gsub('.{3}$', 'LOF', SETID_All))

prkn_setid_dafr <- as.data.frame(cbind(rep(SETID, each=length(prkn_cnv_uniq)), rep(prkn_cnv_uniq, times=length(SETID))))

names(prkn_cnv_uniq_dafr) <- c("chr", "SNP", "morgan", "pos")

map_wCNV <- rbind(map, prkn_cnv_uniq_dafr)

ped_snv <- ncol(ped)
ped_cnv <- (ped_snv+1):(ped_snv+2*length(prkn_cnv_uniq))
ped[, ped_cnv] <- 0

for(i in 1:nrow(cnv_file)){
	s_num <- cnv_file[i,1]
	cnv <- cnv_file[i,2]
	if(any(ped$V1 == s_num)){
		if(is.na(cnv)){
			next
		} else if(cnv == 0){
			ped[ped$V1 == s_num, ped_cnv] <- "C"
		} else {
			ped[ped$V1 == s_num, ped_cnv] <- "C"
			cnv_type <- grep(cnv, prkn_cnv_uniq)
			cnv_pos <- ped_cnv[(2*cnv_type-1):(2*cnv_type)]			
			ped[ped$V1 == s_num, cnv_pos] <- c("A", "C")
			if(grepl("HOM", cnv) == TRUE){
				ped[ped$V1 == s_num, cnv_pos] <- c("A", "A")
			}
		}
	}
}

write.table(ped, file = gsub('.{4}$', '_wCNV.ped', args[1]), quote = F, row.names = F, col.names = F)
write.table(map_wCNV, file = gsub('.{4}$', '_wCNV.map', args[2]), quote = F, row.names = F, col.names = F)
write.table(rbind(SETID_file,prkn_setid_dafr), file = gsub('.{6}$', '_wCNV.SETID', args[4]), quote = F, row.names = F, col.names = F)
