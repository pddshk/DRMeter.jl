include("src/DRMeter.jl")

using .DRMeter

using FileIO: load
using Statistics: mean
import LibSndFile

function _raw_data_and_fs(file::AbstractString)::Tuple{Matrix{Float32}, Int}
    _, ext = splitext(file)
    if ext == ".flac"
        load(file)
    end
end

function _analyze_block(block::AbstractVector{<:AbstractFloat})
    rms = sqrt(2) .* sqrt.(mean(abs2, block))
    peak = maximum(abs, block)
    return [rms peak]
end

to_db(x) = 20log10(x)

function dr_per_channel(data::AbstractVector{<:AbstractFloat}, blocksize::Integer)
    nblocks = size(data, 1) ÷ blocksize
    indstarts = (0:nblocks-1) .* blocksize .+ 1
    slices = @views (data[i:i+blocksize] for i in indstarts)
    res = sort!(mapreduce(_analyze_block, vcat, slices); dims=1, rev=true)
    nchannels = size(res, 2) ÷ 2
    rmss = @view res[:, 1:nchannels]
    peaks = @view res[:,nchannels+1:2nchannels]
    ntoppeaks = round(Int, 0.2 * length(peaks))
    rms_pressure = sqrt.(mean(abs2, @view rmss[1:ntoppeaks]))
    peak = peaks[2]
    to_db(peak/rms_pressure)
end

function dynamic_range(file::AbstractString; blocksize_seconds=3)
    data, fs::Int = _raw_data_and_fs(file)
    nchannels = size(data, 2)
    blocksize = round(Int, blocksize_seconds * fs)
    drs = [dr_per_channel(data[:, i], blocksize) for i in 1:nchannels]
    return round(Int, mean(drs)), drs
end

dynamic_range("dr10.flac")
dynamic_range("03 - Robot Rock.flac")
dynamic_range("A3. Robot Rock.flac")
dynamic_range("Stryper - Against The Law [10].flac")
dynamic_range("11 Circle With Me.flac")