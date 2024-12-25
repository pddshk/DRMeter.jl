module DRMeter

using FileIO: load
using Statistics: mean
import LibSndFile

export dynamic_range

BLOCKSIZE_SECONDS = 3
UPMOST_BLOCKS_RATIO = 0.2
NTH_HIGHEST_PEAK = 2

MIN_BLOCK_COUNT = floor(Int, 1 / UPMOST_BLOCKS_RATIO)
MIN_DURATION = MIN_BLOCK_COUNT * BLOCKSIZE_SECONDS

function _raw_data_and_fs(file::AbstractString)
    _, ext = splitext(file)
    if ext == ".flac"
        load(file)
    end
end

function analyze_block(block)
    rms = sqrt(2) * sqrt.(mean(abs2, block; dims=1))
    peak = maximum(abs, block; dims=1)
    return rms, peak
end

function dynamic_range(file::AbstractString)
    raw = _raw_data_and_fs(file)
    return raw
end

end