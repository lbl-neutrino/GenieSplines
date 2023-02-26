#!/usr/bin/env bash

mkdir -p input/nuclei
./prep_input.py --filter-from splines/nuclei > input/nuclei/input.txt

seq 24 | parallel -n0 -u ./spline_worker.py -i input/nuclei/input.txt -o splines/nuclei --xsec splines/D22_22a_00_000_nucleons_DUNEv1.1_spline.xml
