#!/bin/bash
#SBATCH --job-name=acapulco_job
#SBATCH --mem-per-cpu=10G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --error=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/flirt.%J.err
#SBATCH --output=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/flirt.%J.out

set -x

module load fsl/fsl-6.0.1
database=$1
path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info
# Reference volume used for registration: set to any T1w image in the sample
ref=${2:?Usage: orient_dim_alc.sh <database> <reference_T1w.nii.gz>}
cd ${path}/enigma/input/

for i in $(ls ${path}/enigma/input/${database}_sub-*); do
id=$(basename $i)

fslreorient2std ${id} s_${id}
flirt -in s_${id} -ref ${ref} -out f_${id}

rm ${id}
rm s_${id}
mv s_${id} ${id}
done
