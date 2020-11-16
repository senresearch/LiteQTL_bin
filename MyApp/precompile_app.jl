using MyApp

println(@__DIR__)
genoprobfile=joinpath(@__DIR__, "..", "data", "spleen-bxd-genoprob.csv")
gmapfile=joinpath(@__DIR__,"..", "data", "BXD_gmap.csv")
cleanphenofile=joinpath(@__DIR__,"..", "data", "spleen-pheno-nomissing.csv")
export_matrix="false"
output_file=joinpath(@__DIR__,"..", "data", "julia_result.csv")

push!(ARGS, genoprobfile)
push!(ARGS, cleanphenofile)
push!(ARGS, gmapfile)
push!(ARGS, export_matrix)
push!(ARGS, output_file)
MyApp.julia_main()
