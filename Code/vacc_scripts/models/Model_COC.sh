#!/bin/bash
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=120

module load apptainer
module load Rtidyverse
module load gcc
module load afni-Rlibs

Rscript scripts/extra/filtering_models.R COC --save

echo "Running model COC"
mkdir -p /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/COC

if [ ! -f /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/COC/Model_COC.nii.gz ]; then
        3dLMEr -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/COC/Model_COC.nii.gz -jobs 120                 -model 'Substance+Age+Sex+eTIV+(1|Database)'                 -qVars 'Age,eTIV'                 -gltCode COC_HC 'Substance : 1*COC -1*HC'                 -dataTable @/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/temp/COC.txt
else
        echo "Model file for COC already exists, skipping."
fi

