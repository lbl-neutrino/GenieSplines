#!/usr/bin/env bash

# Reload in Shifter if necessary
image=mjkramer/sim2x2:genie_edep.LFG_testing.20230228
if [[ "$SHIFTER_IMAGEREQUEST" != "$image" ]]; then
    shifter --image=$image --module=none -- "$0" "$@"
    exit
fi

source /environment             # provided by the container

outdir=$1; shift
flav=$1; shift
targ=$1; shift
inputXsec=$1; shift

tune=D22_22a_02_11b

## Spline parameters
nknots=250
e_max=100

if [[ -n "$inputXsec" ]]; then
    input_args=( --input-cross-sections "$(realpath "$inputXsec")" )
else
    input_args=()
fi

mkdir -p "$outdir"

outFileName=$outdir/${tune}_${flav}_${targ}.LFG_testing.20230228.spline.xml

# It looks like running in a temp directory is unnecessary. But maybe it's a
# good idea in case GENIE produces a coredump?

tempdir=tmp/$(basename "$outFileName").d

# need to get the full path since we're cd'ing into tempdir
outFileName=$(realpath "$outFileName")
mkdir -p "$tempdir"

( cd "$tempdir" && \
    gmkspl --tune "$tune" -p "$flav" -t "$targ" -n "$nknots" \
    -e "$e_max" -o "$outFileName" "${input_args[@]}" )
