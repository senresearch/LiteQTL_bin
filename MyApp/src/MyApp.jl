module MyApp


using LMGPU
using DelimitedFiles

function julia_main()

    try
        main()
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

function main()

    @info "getting args"

    geno_file = ARGS[1]
    pheno_file = ARGS[2]
    gmap_file = ARGS[3]
    export_matrix = ARGS[4] == "true"
    output_file = ARGS[5]

    @info "getting geno file and pheno file"

    LMGPU.set_blas_threads(16);

    #change to set computation with Float32 or Float64
    datatype = Float64 
    # Read in data.
    G = LMGPU.get_geno_data(geno_file, datatype)
    Y = LMGPU.get_pheno_data(pheno_file, datatype, transposed=false)
    # getting geno and pheno file size.
    n = size(Y,1)
    m = size(Y,2)
    p = size(G,2)
    println("******* Indivuduals n: $n, Traits m: $m, Markers p: $p ****************");
    # cpu_timing = benchmark(5, cpurun, Y, G,n,export_matrix);

    # running analysis.
    lod = LMGPU.cpurun(Y, G,n,export_matrix);
    if !export_matrix
        gmap = LMGPU.get_gmap_info(gmap_file)
        idx = trunc.(Int, lod[:,1])
        # gmap[1] is data cells. 
        gmap_info = LMGPU.match_gmap(idx, gmap[1])
        gmap_with_header = vcat(gmap[2], gmap_info)
        lod_with_header = vcat(reshape(["idx", "lod"], 1,:), lod)
        lod = hcat(gmap_info, lod)
        # header = reshape(["marker", "chr", "pos", "idx", "lod"], 1,:)
        # lod = vcat(header, lod)
    end

    # write output to file
    writedlm(output_file, lod, ',')
    println("Lod exported to $(abspath(output_file))")

    return lod

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

end # module
