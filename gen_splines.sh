#!/usr/bin/env bash

## Free nucleons
nucleons_arr=( 1000000010 1000010010 )

## Nuclei (get from max path file)
nuclei_arr=( 1000050110 1000060120 1000070140 1000080160 1000110230 1000120240 1000130270 1000140280 1000150310 1000160320 1000170350 1000180400 1000190390 1000200400 1000220480 1000240520 1000250550 1000260560 1000280590 1000300640 1000822070 )

flavor_arr=( 14 -14 12 -12 16 -16 )
tune=D22_22a_00_000

## Spline parameters
nknots=250
e_max=100

outbase=splines

## Max number of targets to run in parallel
## Since there are six flavors, the actual # of processes is 6*maxParTargs
maxParTargs=3

mode=$1; shift

if [[ "$mode" == "nucleons" ]]; then
    target_arr=( "${nucleons_arr[@]}" )
    input_args=""
    # merged_output="$"
elif [[ "$mode" == "nuclei" ]]; then
    target_arr=( "${nuclei_arr[@]}" )
    input_args=( --input-cross-sections "$(realpath "$outbase/${tune}_nucleons_DUNEv1.1_spline.xml")" )
else
    echo "First arg should be nucleons or nuclei"
    exit 1
fi

outdir=$outbase/$mode
mkdir -p "$outdir"

## chunking an array: https://stackoverflow.com/questions/23747612/how-do-you-break-an-array-in-groups-of-n

for ((i=0; i < ${#target_arr[@]}; i+=maxParTargs)); do
    these_targets=( "${target_arr[@]:i:maxParTargs}" )
    for targ in "${these_targets[@]}"; do
        for flav in "${flavor_arr[@]}"; do
            outFileName=$outdir/${tune}_${flav}_${targ}_DUNEv1.1_spline.xml
            tempdir=tmp/$outFileName.d
            # need to get the full path since we're cd'ing into tempdir
            outFileName=$(realpath "$outFileName")
            mkdir -p "$tempdir"
            ( cd "$tempdir" && \
                gmkspl --tune "$tune" -p "$flav" -t "$targ" -n "$nknots" \
                -e "$e_max" -o "$outFileName" "${input_args[@]}" ) &
        done
    done
    wait
done
