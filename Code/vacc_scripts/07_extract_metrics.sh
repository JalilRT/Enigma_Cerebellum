#!/bin/bash

module load singularity/3.7.1
module load freesurfer/freesurfer-6.0.0
path=$(pwd)

acapulco=${path}/enigma/acapulco
freesurfer=${path}/enigma/freesurfer
Rstuff=${path}/QC_file/QC

drug=$1
hemis=$2 #lh or rh
atlas=$3 #aparc.a2009s or DKTatlas
metric=$4 #thickness, volume, meancurv or area

cd ${freesurfer}/${drug}
export SUBJECTS_DIR=$PWD

aparcstats2table --hemi ${hemis} --subjects $(dirname $(dirname $(ls -d *_T1w/stats/${hemis}.${atlas}.stats))) \
 --parc ${atlas} --meas ${metric} --tablefile ${hemis}.${atlas}.${metric}.txt

