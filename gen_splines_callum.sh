#!/bin/bash

## Where to save the output
outDir=${PWD}

## Need to start with free nucleon XSECS
target_arr=( 1000000010 1000010010 )
# target_arr=( 1000060120 1000080160 1000180400 )
flavor_arr=( 14 -14 12 -12 16 -16 )
tune_arr=( CRPA21_04a_00_000 )

## Spline parameters
nknots=250
e_max=100

## Loop over targets
for targ in "${target_arr[@]}"; do

    ## Loop over flavours
    for flav in "${flavor_arr[@]}"; do

	## Loop over requested tunes
	for tune in "${tune_arr[@]}"; do

	    ## The file I want to produce
	    outFileName=${tune}_${flav}_${targ}_v320_spline.xml
	    echo "Processing ${outFileName}"

	    jobScript=${outFileName/.xml/.sh}
	    tempDir=${SCRATCH}/${outFileName/.xml/}

	    ## Start to make the batch file
	    echo "#!/bin/bash" > ${jobScript}
	    echo "#SBATCH --image=docker:wilkinsonnu/nuisance_project:genie_v3.2.0_crpa" >> ${jobScript}
	    echo "#SBATCH --qos=shared" >> ${jobScript}
	    echo "#SBATCH --constraint=haswell" >> ${jobScript}
	    echo "#SBATCH --time=2880" >> ${jobScript}
	    echo "#SBATCH --nodes=1" >> ${jobScript}
	    echo "#SBATCH --ntasks=1" >> ${jobScript}
	    echo "#SBATCH --mem=1GB" >> ${jobScript}

	    ## Set up an area to do this in
	    echo "mkdir ${tempDir}" >> ${jobScript}
	    echo "cd ${tempDir}" >> ${jobScript}

	    echo "cp /global/homes/c/cwilk/make_genie_splines/${tune}_v320_splines.xml ." >> ${jobScript}

	    ## This is the real business (for free nucleons)
	    echo "shifter -V ${PWD}:/output --entrypoint \
	    gmkspl -p ${flav} -t ${targ} -n ${nknots} -e ${e_max} -o ${outFileName} --tune ${tune}" >> ${jobScript}

	    ## For nuclei with free nucleon input
	    ## merge free nucleon inputs into a single spline file to pass as input with gspladd
	    #echo "shifter -V ${PWD}:/output --entrypoint \
            #gmkspl -p ${flav} -t ${targ} -n ${nknots} -e ${e_max} -o ${outFileName} --tune ${tune} \
	    #--input-cross-sections ${tune}_v320_splines.xml" >> ${jobScript}

	    ## Save and clean up
	    echo "cp ${outFileName} ${outDir}/." >> ${jobScript}
	    echo "rm -r ${tempDir}" >> ${jobScript}

	    ## Submit and delete
	    sbatch ${jobScript}
	    rm ${jobScript}
	done
    done
done
