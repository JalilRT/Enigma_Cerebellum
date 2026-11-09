#!/bin/bash

#################################
## 2023-12-12
## Created by JalilRT

path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info
mkdir -p ${path}/scripts/models
mkdir -p ${path}/enigma/models/temp
container=${path}/singularity_files/afni.sif
cd ${path}

#################################

for i in ALC ATS CANN COC NIC OPI User; do

cat << EOF > ${path}/scripts/models/Model_${i}.sh
#!/bin/bash
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=120

module load apptainer
module load Rtidyverse
module load gcc
module load afni-Rlibs

Rscript scripts/extra/filtering_models.R ${i} --save

echo "Running model ${i}"
mkdir -p ${path}/enigma/models/${i}

if [ ! -f /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/${i}/Model_${i}.nii.gz ]; then
        3dLMEr -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/${i}/Model_${i}.nii.gz -jobs 120 \
                -model 'Substance+Age+Sex+eTIV+(1|Database)' \
                -qVars 'Age,eTIV' \
                -gltCode ${i}_HC 'Substance : 1*${i} -1*HC' \
                -dataTable @/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/temp/${i}.txt
else
        echo "Model file for ${i} already exists, skipping."
fi

EOF

sbatch ${path}/scripts/models/Model_${i}.sh

done

# apptainer exec -B $PWD:$PWD ${container} \
#  3dMvM -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/Model_${i}.nii.gz -jobs 120 \
#         -model 'Substance+Age+Sex+eTIV' \
#         -qVars 'Age,eTIV' \
#         -qVarsCenter 0 \
#         -GES \
# 	-num_glt 1 \
#         -gltLabel 1 ${i}_HC -gltCode 1 'Substance : 1*${i} -1*HC' \
#         -dataTable @/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models/temp/${i}.txt