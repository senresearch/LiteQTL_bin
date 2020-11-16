library(qtl)
library(stringr)

timefunc <- function(message, func, ...){
  t = system.time({
    val = func(...)
  })
  print("--------")
  print(t)
  print("--------")
  return (val)
}
getmatchingBXD <- function(phenonames, genonames){
  # find all the matching columnnames in pheno and geno. 
  matched = phenonames[which(phenonames %in% genonames)]
  # filter out BXD columns. They start with B
  return (matched[str_detect(matched,"^B+.")])
}
reorgdata<-function(genofile, phenofile, cleanphenofile, genoprobfile, gmapfile){
  
  pheno <- read.csv(phenofile,skip=32,sep="\t",colClasses="character",na.strings="")
  print("Done reading phenotype. ")
  ## read genotype file as character
  geno <- read.csv(genofile,sep="\t",skip=21,colClasses="character",na.strings="")
  print("Done reading genotype. ")
  rqtlgenofile="temprqtlgeno.csv"
  # rqtlphenofile="./data/processed/temprqtlpheno.csv"

  ########################
  ## expression traits
  ########################
  # remove individuals that has all NAs. 
  emptyindiv <- which(colSums(is.na(pheno))>nrow(pheno)-1)
  pheno <- pheno[,-emptyindiv]
  # find individuals that has data in both pheno and geno. 
  matchingbxds <- getmatchingBXD(names(pheno), names(geno))
  phenobxd <- pheno[,matchingbxds]
  # get probeset column, this will be used as IDs. Then combine with BXD columbs. 
  subpheno <- cbind(pheno$ProbeSet, phenobxd)
  #change "ProbeSet" to "ID", this is to match rqtl format, ID column must match with genotype
  colnames(subpheno)[1] = "ID"
  # remove individuals that has missing data. 
  drop.idx<-which(rowSums(is.na(subpheno))>0)
  subpheno<-subpheno[-drop.idx,]
  write.csv(subpheno, file=cleanphenofile, row.names=FALSE)

  ########################
  ## genotypes
  ########################z
  genobxd <- geno[,matchingbxds]
  gmap <- geno[,c("Locus","Chr","cM","Mb")]
  write.csv(gmap, file=gmapfile, na="")
  # get probeset column, this will be used as IDs. 
  subgeno <- cbind(geno$Locus, geno$Chr, geno$cM, geno[,matchingbxds])
  # changed columns
  colnames(subgeno)[1:3] = c("ID", "", "")
  write.csv(subgeno, file=rqtlgenofile, row.names=FALSE)

  bxd <- read.cross("csvsr", ".", rqtlgenofile, cleanphenofile, crosstype = "risib", genotypes = c("B", "D"))

  if (file.exists(rqtlgenofile)) {file.remove(rqtlgenofile)}
  # if (file.exists(rqtlphenofile)) {file.remove(rqtlphenofile)}

  library(parallel)
  library(qtl2)
  cvt1<-convert2cross2(bxd)
  print(paste("Number of chromosomes is", n_chr(cvt1)))
  map <- insert_pseudomarkers(cvt1$gmap, step=0)
  pr <- calc_genoprob(cvt1, map, error_prob=0.002, cores=1)
  print("done calc genoprob")
  write.csv(pr, file=genoprobfile, row.names=FALSE)
}

args = commandArgs(trailingOnly=TRUE)
reorgdata(args[1], args[2], args[3], args[4], args[5])


