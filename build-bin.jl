using PackageCompiler

app_dir = joinpath(@__DIR__, "MyApp")
println(app_dir)
compile_dir = joinpath(@__DIR__, "Compiled")
println(compile_dir)
precompile_file = joinpath(app_dir,"precompile_app.jl")
# create_app(app_dir, compile_dir, force=true,incremental=false)
create_app(app_dir, compile_dir, force=true,incremental=true,precompile_execution_file=precompile_file)