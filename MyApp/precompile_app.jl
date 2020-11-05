using MyApp

println(@__DIR__)
genoprobfile=joinpath(@__DIR__, "..", "data", "processed", "spleen-bxd-genoprob.csv")
gmapfile=joinpath(@__DIR__,"..", "data", "processed", "BXD_gmap.csv")
cleanphenofile=joinpath(@__DIR__,"..", "data", "processed", "spleen-pheno-nomissing.csv")
export_matrix="false"
output_file=joinpath(@__DIR__,"..", "data", "processed", "julia_result.csv")

push!(ARGS, genoprobfile)
push!(ARGS, cleanphenofile)
push!(ARGS, gmapfile)
push!(ARGS, export_matrix)
push!(ARGS, output_file)
MyApp.julia_main()
