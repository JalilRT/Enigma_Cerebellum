#!/bin/bash

module load singularity/3.7.1
path=$(pwd)

acapulco=${path}/enigma/acapulco
freesurfer=${path}/enigma/freesurfer
Rstuff=${path}/QC_file/QC

cp ${Rstuff}/QC* $path/enigma/acapulco/

echo "which substance want to run? p.e. alcohol = ALC"
substance=$1
#read substance

cd $acapulco

singularity exec --cleanenv -B /gpfs2:/gpfs2 ${Rstuff}/R.sif Rscript QC_Master.R ${acapulco}/output/ya/$substance ${freesurfer}/${substance}
#singularity exec -B $PWD:/$PWD R.sif QC_Master.R output/
mv $path/enigma/acapulco/QC+vols $path/enigma/acapulco/${substance}_QC+vols

rm QC_*
