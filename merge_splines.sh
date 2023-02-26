#!/usr/bin/env bash

# gspladd -f spline1.xml,spline2.xml -o merged.xml

# gspladd -d DIRECTORY_WITH_SPLINE_FILES_TO_MERGE -o merged.xml

mode=$1; shift

tune=D22_22a_00_000

outbase=splines

if [[ "$mode" == "nucleons" ]]; then
    gspladd -d "$outbase"/nucleons -o $outbase/${tune}_nucleons_DUNEv1.1_spline.xml
elif [[ "$mode" == "nuclei" ]]; then
    gspladd -d $outbase/nuclei -o $outbase/${tune}_nuclei_DUNEv1.1_spline.xml
    gspladd -f $outbase/${tune}_nucleons_DUNEv1.1_spline.merged.xml,$outbase/${tune}_nuclei_DUNEv1.1_spline.merged.xml \
        -o $outbase/${tune}_all_DUNEv1.1_spline.xml
else
    echo "First arg should be nucleons or nuclei"
    exit 1
fi
