run_analysis <- function(ref, otus){
	ref_otus <- otus[[ref]]
	n_otus <- length(ref_otus)

	cultured <- sum(ref_otus %in% otus[["cultured"]])
	pcr <- sum(ref_otus %in% otus[["pcr"]])
	sc <- sum(ref_otus %in% otus[["sc"]])
	em_pcr <- sum(ref_otus %in% otus[["em_pcr"]])
	em_meta <- sum(ref_otus %in% otus[["em_meta"]])
	freq <- c(cultured=cultured, pcr=pcr, sc=sc, em_pcr=em_pcr, em_meta=em_meta)
	freq[ref] <- sum(!ref_otus %in% unique(unlist(otus[ !names(otus) %in% ref])))

	if(n_otus != 0){
		percentage <- 100 * freq / n_otus
	} else {
		percentage <- c(cultured=NA, pcr=NA, sc=NA, em_pcr=NA, em_meta=NA)
	}

}


compare_methods <- function(db){

	cultured_otus <- unique(db[db$cultured, "X0.03"])
	pcr_otus <- unique(db[db$pcr, "X0.03"])
	sc_otus <- unique(db[db$single_cell, "X0.03"])
	em_pcr_otus <- unique(db[db$emirge_pcr, "X0.03"])
	em_meta_otus <- unique(db[db$emirge_meta, "X0.03"])

	total_otus <- length(unique(db[,"X0.03"]))

	n_cult_otus <- length(cultured_otus)
	n_pcr_otus <- length(pcr_otus)
	n_sc_otus <- length(sc_otus)
	n_em_pcr_otus <- length(em_pcr_otus)
	n_em_meta_otus <- length(em_meta_otus)

	otu_list <- list(cultured=cultured_otus, pcr=pcr_otus, sc=sc_otus,
					em_pcr=em_pcr_otus, em_meta=em_meta_otus)

	percentages <- t(sapply(names(otu_list), run_analysis, otus=otu_list))
	n_seqs <- c(cultured=sum(db$cultured), pcr=sum(db$pcr), sc=sum(db$single_cell),
					em_pcr=sum(db$emirge_pcr), em_meta=sum(db$emirge_meta))
	n_otus <- c(cultured=length(cultured_otus), pcr=length(pcr_otus),
				sc=length(sc_otus), em_pcr=length(em_pcr_otus),
 				em_meta=length(em_meta_otus))
	cbind(percentages, n_seqs, n_otus)
}

bact <- read.table(file='data/process/bacteria.v123.metadata', header=T, row.names=1, stringsAsFactors=FALSE)
b_overlap <- compare_methods(bact)
b_overlap <- cbind(domain="bacteria", method=rownames(b_overlap), b_overlap)

arch <- read.table(file='data/process/archaea.v123.metadata', header=T, row.names=1, stringsAsFactors=FALSE)
a_overlap <- compare_methods(arch)
a_overlap <- cbind(domain="archaea", method=rownames(a_overlap), a_overlap)

write.table(rbind(b_overlap, a_overlap), "data/process/otu_overlap_by_method.tsv", quote=F, sep='\t', row.names=F)
