using Pkg

Pkg.add(url="https://github.com/senresearch/LiteQTL.jl")

Pkg.activate("./MyApp")
Pkg.instantiate(; verbose = false)

