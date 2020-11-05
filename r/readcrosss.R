library(qtl)
getmatchingBXD <- function(phenonames, genonames){
  # find all the matching columnnames in pheno and geno. 
  matched = phenonames[which(phenonames %in% genonames)]
  # filter out BXD columns. They start with B
  return (matched[str_detect(matched,"^B+.")])
}

pheno <- read.csv(phenofile,skip=32,sep="\t",colClasses="character")
print("Done reading phenotype. ")

## read genotype file as character
geno <- read.csv(genofile,sep="\t",skip=21,colClasses="character")
print("Done reading genotype. ")
########################
## expression traits
########################
matchingbxds <- getmatchingBXD(names(pheno), names(geno))
phenobxd <- pheno[,matchingbxds]
# get probeset column, this will be used as IDs. Then combine with BXD columbs. 
subpheno <- cbind(pheno$ProbeSet, phenobxd)
#change "ProbeSet" to "ID", this is to match rqtl format, ID column must match with genotype
colnames(subpheno)[1] = "ID"

write.csv(subpheno, file=cleanphenofile, row.names=FALSE)
########################
## genotypes
########################

genobxd <- geno[,matchingbxds]
# get probeset column, this will be used as IDs. 
subgeno <- cbind(geno$Locus, geno$Chr, geno$cM, geno[,matchingbxds])
# changed columns
colnames(subgeno)[1:3] = c("ID", "", "")
write.csv(subgeno, file=cleangenofile, row.names=FALSE)

bxd <- read.cross("csvsr", "./data/processed", "rqtlgeno.csv", "rqtlpheno.csv", crosstype = "risib", genotypes = c("B", "D"))

