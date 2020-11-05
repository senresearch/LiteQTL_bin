#!/bin/bash

######################
# This file will run with data using raw data format 
######################

# Your raw genotype file
genofile="./data/raw/bxd.geno" 
# Your raw phenotype file
phenofile="./data/raw/bxdspleen.txt"
# Phenotype file with no missing. Will be input for Julia scan
cleanphenofile="./data/processed/spleen-pheno-nomissing.csv"
# Genotype probability file. Will be input for Julia scan
genoprobfile="./data/processed/spleen-bxd-genoprob.csv"
gmapfile="./data/processed/BXD_gmap.csv"

Rscript --vanilla ./r/cleaning_raw.R $genofile $phenofile $cleanphenofile $genoprobfile $gmapfile

# If export_matrix set to true, then the entire LOD score matrix will be exported. If false, only maximum lod and related gmpa info will be exported.
export_matrix="false"
# genome scan results.
output_file="./data/processed/julia_result.csv"
# rqtl_file is needed to find gmap.csv.

time JULIA_NUM_THREADS=16 julia ./MyApp/src/MyApp.jl $genoprobfile $cleanphenofile $gmapfile $export_matrix $output_file