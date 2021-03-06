[LiteQTL.jl](https://github.com/senresearch/LiteQTL.jl) is a package that speeds up eQTL scans. This repository contains code to create a command line interface to LiteQTL.jl; you can create a binary to remove the JIT compilation cost of Julia. The repository also contains examples for testing your build. Currently, this script builds a binary for the CPU version of LiteQTL.jl. 

## Dependencies and build instructions

The build code assumes you are working in Linux.  You will need
`wget`, R and Julia. You will also need the following R 
packages: `parallel`, `qtl`, `qtl2`, `stringr`.

The following steps assume that you are in the top-level directory of this repo.

To install the Julia dependencies:  
    `julia install_packages.jl`  
Before compiling, make sure the (interpreted JIT compiled) toolchain is working:  
    `./sh/testrun.sh`  
To build the binaries:  
    `julia build_bin.jl`  
Test your build:  
    `./sh/run_genome_scan.sh`

## Details and notes

### 1. Process of running eQTL genome scan. 
There are two steps:  
1. We use R to clean genotypes and phenotypes and calculate genotype probabilities with R/qtl. (see `./r/clean_raw_data.R`) 
2. Then we use Julia to run genome scan (see `./MyApp/src/MyApp.jl`). The purpose of having two steps is to seperate data cleaning from the genome scans.  The data cleaning needs to be done once, and the result can be cached to be reused by the genome scan in step 2. 

To see an example of running a genome scan with both steps, please see `./sh/run_genome_scan.sh`. 

#### 1.1 The data cleaning step will do the following: 
- collect all individuals that have both phenotypes and genotypes
- remove individuals with missing data (genotypes of phenotypes)
- extract gmap information (marker map) and write out to a file 
- calculate genotype probabilities using R/qtl2

Command line input required are:
- genotype data (input)
- phenotype data (input)
- filename of the cleaned phenotype data (output)
- filename of the genotype probability (output)
- filename of gmap information (output)

Three output files will be used by the second step (eQTL scan in Julia). 

#### 1.2 The genome scan step will do the following: 
- run genome scan, the result is a LOD score matrix
- depending on the command line input of `export_matrix`, we will write out the whole matrix, or calculate the maximum LOD score of each phenotype

Command line input required are (in the order specified below):
- genotype probability file (input)
- cleaned phenotype data file (input)
- gmap information file (input)
- `export_matrix` option (input); if `true`, a matrix of LOD scores will be returned; if `false` just the maximum LOD for each phenotype is returned (the latter is faster) 
- LOD score file (output)

If `export_matrix` is set to `false`, the file will contain the marker information (index, locus, chromosome, marker cM and Mb), and the the value of the maximum LOD.

### 2. How to build the binary 

We use `PackageCompiler.jl` to build the binary. The build process follows the rules and standards of Julia's package system. 
Please run step 1 (R data cleaning) to generate necessary data files required by the precompilation. You can verify that the interpreted JIT compiled toolchain is working correctly by running `./sh/testrun.sh`.

To build the binary, run the following in terminal:

    julia build_bin.jl

Building the binary will generate a folder called `Compiled`, the subfolders are `artifacts`, `bin`, `lib`. All three folders are required if you want to relocate the binary elsewhere. The binary is `./Compiled/bin/scan`. 

### 3. How to use the binary 

See the last line in `./sh/run_genome_scan.sh`. 

The arguments are the same and in the same order as in section 1.2.

To run the scan with 16 CPU threads with just maximum LOD scores, use

    JULIA_NUM_THREADS=16 julia ./Compiled/bin/scan genoprobfile cleanphenofile gmapfile false output_file
