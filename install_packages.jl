using Pkg

Pkg.add(url="https://github.com/senresearch/LMGPU.jl")

Pkg.activate("./MyApp")
Pkg.instantiate(; verbose = false)

