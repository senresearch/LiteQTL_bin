#!/bin/bash

######################
# This file will run with data using raw data format 
######################

# SPLEEN DATA

# Your raw genotype file
genofile="./data/raw/bxd.geno" 
# Your raw phenotype file
phenofile="./data/raw/bxdspleen.txt"
# Phenotype file with no missing. Will be input for Julia scan
cleanphenofile="./data/spleen-pheno-nomissing.csv"
# Genotype probability file. Will be input for Julia scan
genoprobfile="./data/spleen-bxd-genoprob.csv"
gmapfile="./data/BXD_gmap.csv"


# HIPPOCAMPUS DATA

# # Your raw genotype file
# genofile="./data/raw/bxd.geno" 
# # Your raw phenotype file
# phenofile="./data/raw/bxdhippo.txt"
# # Phenotype file with no missing. Will be input for Julia scan
# cleanphenofile="./data/hippo-pheno-nomissing.csv"
# # Genotype probability file. Will be input for Julia scan
# genoprobfile="./data/hippo-bxd-genoprob.csv"
# gmapfile="./data/BXD_gmap.csv"

time Rscript --vanilla ./r/clean_raw_data.R $genofile $phenofile $cleanphenofile $genoprobfile $gmapfile


# SPLEEN DATA 
# If export_matrix set to true, then the entire LOD score matrix will be exported. If false, only maximum lod and related gmpa info will be exported.
export_matrix="false"
# genome scan results.
output_file="./data/spleen_julia_result.csv"

# # HIPPO DATA 
# export_matrix="false"
# # genome scan results.
# output_file="./data/hippo_julia_result.csv"


# # to run with julia script. (not compiled)
# time JULIA_NUM_THREADS=16 julia ./MyApp/src/MyApp.jl $genoprobfile $cleanphenofile $gmapfile $export_matrix $output_file

# # to run with compiled version of genome scan
time JULIA_NUM_THREADS=16 ./Compiled/bin/scan $genoprobfile $cleanphenofile $gmapfile $export_matrix $output_file