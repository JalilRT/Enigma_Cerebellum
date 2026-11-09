#!/bin/bash
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=120

module load apptainer
module load Rtidyverse
module load gcc
module load afni-full

Rscript scripts/extra/filtering_models_CC.R ALC --save

echo "Running model ALC"
mkdir -p /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/ALC

if [ ! -f /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/ALC/Model_ALC.nii.gz ]; then
       3dLMEr -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/ALC/Model_ALC.nii.gz -jobs 120                 -model 'Substance+Age+Sex+eTIV+(1|Database)'                 -qVars 'Age,eTIV'                 -gltCode ALC_HC 'Substance : 1*ALC -1*HC'                 -dataTable @/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/temp/ALC.txt
else
        echo "File /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/ALC/Model_ALC.nii.gz exists, skipping."
fi

