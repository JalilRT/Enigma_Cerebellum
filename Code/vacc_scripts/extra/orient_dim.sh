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
cd ${path}/enigma/input/

for i in $(ls ${path}/enigma/input/${database}_sub-*); do
id=$(basename $i)

fslreorient2std ${id} s_${id}
fslorient -swaporient s_${id}

rm ${id}
mv s_${id} ${id}

done
