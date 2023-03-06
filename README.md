# Onetime setup

``` bash
./install.sh
```

# Loading the "launch" environment

This is the environment you use for preparing inputs and launching workers.

``` bash
source setup.sh
```

# Entering the GENIE container

This is the environment you use for running `gspladd`.

``` bash
shifter --image=mjkramer/sim2x2:genie_edep.LFG_testing.20230228 /bin/bash --init-file /environment
```

Note that the `run_gmkspl.sh` script is meant to be called from outside the
container (e.g. by `spline_worker.py`). Internally, the script enters the
container.


# Making splines

These instructions assume you're working with the `LFG_testing.20230228` tag of
GENIE and the `D22_22a_02_11b` tune. Feel free to change those values in
`run_gmkspl.sh` and in the commands below.

## First, free nucleons

### Prepare input for free nucleons

``` bash
mkdir -p input/nucleons
./prep_input.py --mode nucleons > input/nucleons/input.txt
```

### Generate splines for free nucleons

``` bash
seq 12 | parallel -n0 -u ./spline_worker.py \
    -i input/nucleons/input.txt -o splines/nucleons
```

It should take about two hours in the worst case, so do this in a screen
session.

### Merge splines for free nucleons

From inside the container:

``` bash
gspladd -d splines/nucleons -o splines/D22_22a_02_11b.nucleons.LFG_testing.20230228.spline.xml
```

This merged file is used as input when generating the splines for nuclei.

## Then, various nuclei

### Prepare input for nuclei

First, open up `prep_input.py` and make sure that the `NUCLEI` variable contains
all of the targets listed in the GENIE max path file for the geometry you plan
to simulate.

``` bash
mkdir -p input/nuclei
./prep_input.py --mode nuclei > input/nuclei/input.txt
```

### Generate splines for nuclei

``` bash
seq 48 | parallel -n0 -u ./spline_worker.py \
    -i input/nuclei/input.txt -o splines/nuclei \
    --xsec splines/D22_22a_02_11b.nucleons.LFG_testing.20230228.spline.xml
```

This took a day or two for the 21 nuclei in the MINERvA+2x2 geometry. Note that
there are six spline files (one per neutrino signed-flavor) for each nucleus, so
in that case, there were 126 total files to produce.

For faster turnaround, you can increase the nunber of workers beyond `24`
(ideally on a batch node). You're free to add more workers at any point.

## Merge all of the splines

From inside the container:

``` bash
gspladd -d splines/nuclei -o splines/D22_22a_02_11b_nuclei_LFG_testing.20230228_spline.xml

gspladd -f splines/D22_22a_02_11b_nucleons_LFG_testing.20230228_spline.xml,splines/D22_22a_02_11b_nuclei_LFG_testing.20230228_spline.xml \
    -o splines/D22_22a_02_11b_all_LFG_testing.20230228_spline.xml 
```

It looks like the second step is redundant; the merged `all` and `nuclei` files
are identical, so I guess the free nucleon cross sections are already embedded
in the spline files for each nucleus.
