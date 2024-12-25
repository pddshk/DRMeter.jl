include("src/DRMeter.jl")

using .DRMeter

main(ARGS) = dynamic_range(ARGS[1])

if abspath(PROGRAM_FILE) == @__FILE__
    println(main(ARGS))
end
