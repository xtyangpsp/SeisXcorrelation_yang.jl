export sort_pairs, get_corrtype
"""

    sort_pairs(pairs::AbstractArray)

Sort station pairs into their correlation category (auto-correlation, cross-correlation, cross-channel-correlation)

# Arguments
- `pairs::AbstractArray,`    : Array of station pairs, e.g. output of generate_pairs(file["info/stationlist"])

# Output
- `sorted_pairs::Dict{String, Array{String, N}}`    : dictionary containing station pairs grouped by correlation type

"""
function sort_pairs(pairs::AbstractArray)
    # dict containing each correlation category
    # preallocation of dict size assumes all stations have the same number of channels, which may not be true.
    sorted_pairs = Dict{String, Array{String}}("acorr"     => ["", ""],
                                               "xcorr"     => ["", ""],
                                               "xchancorr" => ["", ""])

    # fill dictionary based on detected correlation type
    for stnPair in pairs
        ct = get_corrtype(stnPair)
        sorted_pairs[ct] = hcat(sorted_pairs[ct], stnPair)
    end

    # remove ["",""] used to initialize dict
    sorted_pairs["acorr"]     = sorted_pairs["acorr"][:, 2:end]
    sorted_pairs["xcorr"]     = sorted_pairs["xcorr"][:, 2:end]
    sorted_pairs["xchancorr"] = sorted_pairs["xchancorr"][:, 2:end]

    return sorted_pairs
end

"""

    corrtype(stnPair::Array{String, 1})

Determine correlation type (cross-correlation, auto-correlation, or cross-channel-correlation) using string slicing.
The station string must be: NET.STA.LOC.CHAN
# Arguments
- `stnPair::Array{String, 1},`    : Station pair, e.g. ["BP.SMNB..BP1", "BP.SMNB..BP3"]

# Output
- `corrtype::String`    : correlation type, e.g. "xchancorr"

"""
function get_corrtype(stnPair::Array{String, 1})
    stn1=join(split(stnPair[1],".")[1:3],".")
    stn2=join(split(stnPair[2],".")[1:3],".")
    chan1=split(stnPair[1],".")[4]
    chan2=split(stnPair[2],".")[4]
    # same station, same channel
    if stnPair[1] == stnPair[2]
        ct = "acorr"
    # same station, different channel
    elseif (stn1 == stn2) && (chan1 != chan2) #(stnPair[1][end-3:end] != stnPair[2][end-3:end]) && (stnPair[1][1:end-3] == stnPair[2][1:end-3])
        ct = "xchancorr"
    # different station
    else
        ct = "xcorr"
    end
    return ct
end
