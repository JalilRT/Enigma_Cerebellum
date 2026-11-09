#!/bin/bash
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=120

module load apptainer
module load Rtidyverse
module load gcc
module load afni-Rlibs

Rscript scripts/extra/filtering_models.R User --save

echo "Running model User"
mkdir -p /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/User

if [ ! -f /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/User/Model_User.nii.gz ]; then
        3dLMEr -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/User/Model_User.nii.gz -jobs 120                 -model 'Substance+Age+Sex+eTIV+(1|Database)'                 -qVars 'Age,eTIV'                 -gltCode User_HC 'Substance : 1*User -1*HC'                 -dataTable @/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/temp/User.txt
else
        echo "Model file for User already exists, skipping."
fi

