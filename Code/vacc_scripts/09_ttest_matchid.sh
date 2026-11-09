#!/bin/bash

#################################
## 2023-12-12
## Created by JalilRT

path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info
mkdir -p ${path}/scripts/models_matchid
mkdir -p ${path}/enigma/models_matchid/temp
container=${path}/singularity_files/afni.sif
cd ${path}

#################################

for i in ALC ATS CANN COC NIC USERS; do #ALC ATS CANN COC NIC USERS

if [ "$i" == "USERS" ]; then
        model_name="User"
else
        model_name="$i"
fi

module load Rtidyverse
Rscript scripts/extra/filtering_models_matchid_harmonized.R ${i} --save

setA_drug_path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_matchid/temp/${i}/drug.txt
setB_hc_path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_matchid/temp/${i}/hc.txt

setA_drug=$(cat ${setA_drug_path} | tr '\n' ' ')
setB_hc=$(cat ${setB_hc_path} | tr '\n' ' ')

cat << EOF > ${path}/scripts/models_matchid/Model_${i}.sh
#!/bin/bash
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=120

module load apptainer
module load Rtidyverse
module load gcc
module load afni-Rlibs

echo "Running model ${i}"
mkdir -p ${path}/enigma/models_matchid/${i}
cd /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_matchid/${i}/

if [ ! -f /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_matchid/${i}/Model_${i}.nii.gz ]; then
        3dttest++ -Clustsim \
                -prefix Model_${i}.nii.gz \
                -mask ${path}/scripts/models_matchid/SUIT_mask.nii.gz \
                -setA $setA_drug \
                -setB $setB_hc
else
        echo "File /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_matchid/${i}/Model_${i}.nii.gz exists, skipping."
fi

EOF

sbatch ${path}/scripts/models_matchid/Model_${i}.sh

done