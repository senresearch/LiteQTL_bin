#!/bin/bash

DATADIR=data
RAWDATADIR=$DATADIR/raw
FILE=./testrun
if [ ! -d "$DATADIR" ]; then 
    mkdir $DATADIR
fi 

if [ ! -d "$RAWDATADIR" ]; then 
    mkdir $RAWDATADIR
fi 


GENOFILE=$RAWDATADIR/bxd.geno
if [ ! -f "$GENOFILE" ]; then 
    # get the data from API 
    # get genotype 
    wget -O $RAWDATADIR/bxd.geno http://genenetwork.org/api/v_pre1/genotypes/BXD.geno
    wget -O $RAWDATADIR/bxdspleen.txt http://datafiles.genenetwork.org/download/GN283/GN283_MeanDataAnnotated_rev081815.txt
    wget -O $RAWDATADIR/bxdhippo.txt http://datafiles.genenetwork.org/download/GN206/GN206_MeanDataAnnotated_rev081815.txt
else 
    echo "Test data already downloaded."
fi

# SPLEEN DATA

# Your raw genotype file
genofile=$RAWDATADIR/bxd.geno
# Your raw phenotype file
phenofile=$RAWDATADIR/bxdspleen.txt
# Phenotype file with no missing. Will be input for Julia scan
cleanphenofile=$DATADIR/spleen-pheno-nomissing.csv
# Genotype probability file. Will be input for Julia scan
genoprobfile=$DATADIR/spleen-bxd-genoprob.csv
gmapfile=$DATADIR/BXD_gmap.csv

Rscript --vanilla ./r/clean_raw_data.R $genofile $phenofile $cleanphenofile $genoprobfile $gmapfile

# SPLEEN DATA 

export_matrix="false"
# genome scan results.
output_file=$DATADIR/spleen_julia_result.csv

# # to run with julia script. (not compiled)
JULIA_NUM_THREADS=16 julia ./MyApp/src/MyApp.jl $genoprobfile $cleanphenofile $gmapfile $export_matrix $output_file
