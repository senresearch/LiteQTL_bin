
## load library
library(tidyverse)
library(data.table)
library(qtl)


reorgdata<-function(genofile, phenofile, cleanphenofile, genoprobfile, gmapfile){

  pheno <- read.csv(phenofile,skip=32,
                sep="\t",colClasses="character")
  print("Done reading phenotype. ")
  
  ## read genotype file as character
  geno <- read.csv(genofile,sep="\t",skip=21,
                colClasses="character")
  print("Done reading genotype. ")

  ########################
  ## expression traits
  ########################

  ## select probeset column
  probeset  <- select(pheno,"ProbeSet")
  ## select BXD columns
  pheno_bxd_cols <- select(pheno,matches("BXD"))
  ## put probeset and BXD together
  chosenpheno  <- cbind(probeset,pheno_bxd_cols)
  ## get the names of each column
  chosenphenonames  <- names(chosenpheno)
  print("Done subsetting phenotype. ")
  ########################
  ## genotypes
  ########################

  ## select marker information columns
  gmap <- select(geno,one_of("Locus","Chr","cM","Mb"))
  write_csv(gmap, path=gmapfile, col_names=TRUE, na="")
  ## select BXD columns
  geno_bxd_cols <- select(geno,matches("BXD"))
  ## put together BXD and marker info
  chosengeno  <- cbind(gmap,geno_bxd_cols)
  ## get the names of each column
  chosengenonames  <- names(chosengeno)
  print("Done subsetting Genotype. ")
  ######################
  ## putting genotype and traits together
  #####################

  ## transpose both genotype and expression data
  ## make the first column the variable names of the tibble
  chosengeno_trans  <- t(chosengeno[,-1])
  colnames(chosengeno_trans) <- chosengeno[,1]
  chosengeno_tb <- as_tibble(chosengeno_trans)
  print("Trsnsposed geno...")
  #
  chosenpheno_trans  <- t(chosenpheno[,-1])
  colnames(chosenpheno_trans)  <- chosenpheno[,1]
  chosenpheno_tb  <- as_tibble(chosenpheno_trans) 
  print("Transposed pheno...")

  ## create id columns for both datasets
  chosengeno_tb$id  <- chosengenonames[-1]
  chosenpheno_tb$id  <- chosenphenonames[-1]
  print("Added ID column.")

  ## make a right join on id
  ## this will keep all the traits with genotypes
  print("Begining right join pheno and geno...")
  genopheno <- right_join(chosenpheno_tb,chosengeno_tb,"id")
  print("Done right join.")

  ## get the rows with the marker info; they don't start with "B"
  genophenoMkinfo <- filter(genopheno,!str_detect(id,"^B+."))
  ## all other rows
  genophenoinfo <- filter(genopheno,str_detect(id,"^B+."))
  ## bind rows and make tibble
  genopheno <- tibble(bind_rows(genophenoMkinfo,genophenoinfo))
  ## sanitize the id column by getting rid of the marker info annotation
#  genopheno$id[!str_detect(genopheno$id,"^B+.")] <- ""
  ## make id the first column 
  genopheno <- relocate(genopheno,id,.before=1)

  ## remove mb positions
  genopheno <- filter(genopheno,id!="Mb")

  transposedf<-function(df){
    library(data.table)
  #   rownames(df) <- df[,1]
    t_df <- transpose(df)
  #   colnames(t_test) <- t_test[1, ]
  #   t_test <- t_test[-1, ]
    rownames(t_df) <- colnames(df)
    colnames(t_df) <- t_df[1, ] 

    return(t_df[-1, ])
  }

  t_genopheno = transposedf(genopheno)
  ## write in R/qtl format
  print("Writing out geno and pheno in rqtl format...")
  rqtlfile = "rqtl_tmp.csv"
  write_csv(cbind(rownames(t_genopheno), t_genopheno),path=rqtlfile,col_names=F, na="")

  bxd <- read.cross(file=rqtlfile,format="csvr",
                    crosstype="risib",genotypes=c("B","D"))
  
  if (file.exists(rqtlfile)) {
    #Delete file if it exists
    file.remove(rqtlfile)
  }

  print(paste("Number of chromosomes is", nchr(bxd)))
  print("done read.cross. ")
  #drop obs. & traits with all NAs (-1 because sex is not counted. )
  keepidx<-which(rowSums(is.na(bxd$pheno))<ncol(bxd$pheno)-1)
  c1<-subset(bxd,ind=keepidx)
  end<-dim(c1$pheno)[2]

  #check NAs
  table(colSums(is.na(c1$pheno)))
  drop.idx<-which(colSums(is.na(c1$pheno))>0)
  c1$pheno<-c1$pheno[,-drop.idx]
  write.csv(c1$pheno, file=cleanphenofile, row.names=TRUE)

  library(parallel)
  library(qtl2)
  cvt1<-convert2cross2(c1)
  print(paste("Number of chromosomes is", n_chr(cvt1)))
  map <- insert_pseudomarkers(cvt1$gmap, step=0)
  prtime <- system.time({
      pr <- calc_genoprob(cvt1, map, error_prob=0.002, cores=1)
  })
  print("Calculating genoprob took: ")
  print(prtime)

  print("done calc genoprob")
  write.csv(pr, file=genoprobfile, row.names=FALSE)

}

args = commandArgs(trailingOnly=TRUE)
reorgdata(args[1], args[2], args[3], args[4], args[5])

