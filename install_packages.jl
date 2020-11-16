using Pkg

Pkg.add(url="https://github.com/chelseatrotter/LMGPU.jl")

# Pkg.activate(".")
# Pkg.instantiate(; verbose = false)
Pkg.activate("./bin/MyApp")
Pkg.instantiate(; verbose = false)

