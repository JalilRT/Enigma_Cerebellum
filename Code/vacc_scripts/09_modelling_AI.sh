#!/bin/bash

#################################
## 2023-12-12
## Created by JalilRT

path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info
mkdir -p ${path}/scripts/models_AI
mkdir -p ${path}/enigma/models_AI/temp
container=${path}/singularity_files/afni.sif
cd ${path}

#################################

for i in USERS; do #ALC ATS CANN COC NIC OPI 

if [ "$i" == "USERS" ]; then
        model_name="User"
else
        model_name="$i"
fi

cat << EOF > ${path}/scripts/models_AI/Model_${i}.sh
#!/bin/bash
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=120

module load apptainer
module load Rtidyverse
module load gcc
module load afni-full

Rscript scripts/extra/filtering_models_AI.R ${i} --save

echo "Running model ${i}"
mkdir -p ${path}/enigma/models_AI/${i}

if [ ! -f /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/${i}/Model_${i}.nii.gz ]; then
       3dLMEr -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/${i}/Model_${i}.nii.gz -jobs 120 \
                -model 'Substance+Age+Sex+eTIV+(1|Database)' \
                -qVars 'Age,eTIV' \
                -gltCode ${i}_HC 'Substance : 1*${model_name} -1*HC' \
                -dataTable @/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/temp/${i}.txt
else
        echo "File /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/${i}/Model_${i}.nii.gz exists, skipping."
fi

EOF

sbatch ${path}/scripts/models_AI/Model_${i}.sh

done

        # 3dLMEr -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/${i}/Model_${i}.nii.gz -jobs 120 \
        #         -model 'Substance+Age+Sex+eTIV+(1|Database)' \
        #         -qVars 'Age,eTIV' \
        #         -gltCode ${i}_HC 'Substance : 1*${model_name} -1*HC' \
        #         -dataTable @/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/temp/${i}.txt

        # 3dMVM -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/${i}/Model_${i}.nii.gz -jobs 120 \
        #         -bsVars "Substance" \
        #         -GES \
        # 	-num_glt 1 \
        #         -gltLabel 1 ${i}_HC -gltCode 1 "Substance : 1*${i} -1*HC" \
        #         -dataTable @/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/temp/${i}.txt

        # 3dttest++ -prefix /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/${i}/Model_${i}.nii.gz -jobs 120 \
        #         -setA /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/temp/${i}.txt` \
        #         -setB `awk '$2=="HC" {print $8}' /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/temp/${i}.txt` \
        # 	-Clustsim