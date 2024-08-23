module PerfusionImaging

# using PythonCall

# const np = PythonCall.pynew()
# const torch = PythonCall.pynew()
# const torchreg = PythonCall.pynew()

# function __init__()
#     PythonCall.pycopy!(np, pyimport("numpy"))
#     PythonCall.pycopy!(torch, pyimport("torch"))
#     PythonCall.pycopy!(torchreg, pyimport("torchreg"))
# end

# export np, torch, torchreg

include("arterial_input_function.jl")
include("flow.jl")
include("gamma_variate.jl")
include("masking.jl")
include("utils.jl")
# include("registration.jl")

end
