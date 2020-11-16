LMGPU.jl is a package that simplifies genome scan process for eQTL scans, to gain significant speed up. This repository contains code to showcase how to use LMGPU to run genome scan, and also how to compile LMGPU to binary to remove the JIT compilation cost of Julia. 

- Process of running eQTL genome scan. 
There are two steps: 1. We use R to clean genotype and phenotype and calculate genotype probability with R/qtl. (see `./r/clean_raw_data.R`) 2. Then we use Julia to run genome scan (see `./MyApp/src/MyApp.jl`). The purpose of having two step is to seperate data cleaning from genome scan process, since data cleaning is a one time cost, the result can be cached to be reused by the genome scan in step 2. 

To see an example of running genome scan with both steps, please see `./sh/run_genome_scan.sh`. 

The data cleaning step will do the following: 
- collect all individuals that has both phenotype and genotype
- remove missing data 
- extract gmap information and write out to file. 
- calculate genotype probability using R/qtl2
Command line input required are:
- genotype data (input)
- phenotype data (input)
- filename of the cleaned phenotype data (output)
- filename of the genotype probability (output)
- filename of gmap information (output)
Three output files will be used by the second step (eQLT scan in Julia). 

The genome scan step will do the following: 
- run genome scan, the result a LOD score matrix
- depending on the command line input of `export_matrix`, we will write out the whole matrix, or calculate the maximum LOD score of each phenotype. 
For second step, input required are: 
- genotype probability (input)
- cleaned phenptype data (input)
- gmap information (input)
- LOD score in the form of matrix or maximum LOD of each phenptype, true if you want matrix, false if you want maximum LOD. 
- filename of the LOD score (output)
The command line input must be in the order specified above. The output file of LOD score will contain only a matrix if `export_matrix` is set to true, if set to false, the file will contain gmap information, index of where the maximum LOD is found, and the the value of maximum LOD. 

- How to build binary 
We used PackageCompiler.jl to build the binary. The binary building process follows the rules and standards of Julia's package system. 
Please run step 1 (R data cleaning) to generate necessary data file, required by the precompilation. Make sure the input and output file names are correct in `./MyApp/precompile_app.jl` 

To build the binary, run the following in terminal:
- `julia install_packages.jl` 
- `julia build_bin.jl`
Building the binary will generate a folder called `Compiled`, the subfolders are `artifacts`, `bin`, `lib`. All three folders are required if you want to relocate the binary to elsewhere. Binary is located in `bin`. 

- How to use the binary 
See the last line in `./sh/run_genome_scan.sh`. 
