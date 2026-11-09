#!/bin/bash
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=120

module load apptainer
module load Rtidyverse
module load gcc
module load afni-full

Rscript scripts/extra/filtering_models_CC.R OPI --save

echo "Running model OPI"
mkdir -p /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/OPI

if [ ! -f /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/OPI/Model_OPI.nii.gz ]; then
       3dLMEr -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/OPI/Model_OPI.nii.gz -jobs 120                 -model 'Substance+Age+Sex+eTIV+(1|Database)'                 -qVars 'Age,eTIV'                 -gltCode OPI_HC 'Substance : 1*OPI -1*HC'                 -dataTable @/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/temp/OPI.txt
else
        echo "File /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_CC/OPI/Model_OPI.nii.gz exists, skipping."
fi

