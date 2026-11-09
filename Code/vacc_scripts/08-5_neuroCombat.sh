#!/bin/bash
#SBATCH --time=04:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=80

#################################
## 2025-04-19
## Created by JalilRT

module load apptainer
module load Rtidyverse
module load fsl
module load python3.10-anaconda/2023.03-1

path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info
path_files=${path}/enigma/suit_stats/wdseg1_files/
mkdir -p ${path}/scripts/models_matchit
mkdir -p ${path}/enigma/models_matchit/temp
container=${path}/singularity_files/afni.sif
cd ${path}

if [ ! -f scripts/input_files_mul.csv ]; then
    Rscript scripts/08_arranging_afni.R
fi

for i in $(tail -n +2 scripts/input_files.csv | cut -d ',' -f 1); do 
    output_file=$(dirname $i)/$(basename ${i} .nii)_mask_01.nii
    if [ ! -f "$output_file" ]; then
        singularity exec -B /gpfs2:/gpfs2 singularity_files/afni.sif 3dcalc -a $i -expr "step(a)" -prefix "$output_file"
    fi
done

echo "Multiplying the mask with the original data..."

for i in $(tail -n +2 scripts/input_files.csv | cut -d ',' -f 1); do 
    output_file=$(dirname $i)/$(basename ${i} .nii)_mul.nii
    if [ ! -f "$output_file" ]; then
        singularity exec -B /gpfs2:/gpfs2 singularity_files/afni.sif 3dcalc -a $i -b $(dirname $i)/$(basename ${i} .nii)_mask_01.nii -expr "1000*(a*b)" -prefix "$output_file"
    fi
done

if [ ! -f scripts/input_files_mul.csv ]; then
    awk -F',' '{if (NR == 0) print $0; else $1=gensub(".nii", "_mul.nii", "g", $1); print $0}' OFS=',' scripts/input_files.csv > scripts/input_files_mul.csv
fi

if [ ! -f enigma/suit_stats/wdseg1_files/my_model ]; then
    python3.10 ${path}/scripts/neuroHarmonize_wb.py
else
    echo "Harmonized already performed"
fi

echo "Removing the negative values"
for i in $(tail -n +2 scripts/input_files_mul.csv | cut -d ',' -f 2); do 
    output_file=$(dirname $i)/$(basename ${i} .nii)_z.nii
    if [ ! -f "$output_file" ]; then
        #fslmaths $i -thr 0 $output_file
        singularity exec -B /gpfs2:/gpfs2 singularity_files/afni.sif 3dcalc -a $i -expr "log10(a)" -prefix $output_file
    fi
done

echo "Calculating mean values for each subject..."

for i in $(tail -n +2 scripts/input_files.csv | cut -d ',' -f 1); do 
    output_file=$(dirname $i)/$(basename ${i} .nii)_mean.txt
    if [ ! -f "$output_file" ]; then
        singularity exec -B /gpfs2:/gpfs2 singularity_files/afni.sif 3dROIstats -mask $(dirname $i)/$(basename ${i} .nii)_mask_01.nii -quiet $(dirname $i)/$(basename ${i} .nii)_mul.nii > "$output_file"
    fi
done

echo "Calculating mean values for harmonized data..."

for i in $(tail -n +2 scripts/input_files_mul.csv | cut -d ',' -f 2); do 
    output_file=$(dirname $i)/$(basename ${i} .nii)_mean_harmonized.txt
    if [ ! -f "$output_file" ]; then
        singularity exec -B /gpfs2:/gpfs2 singularity_files/afni.sif 3dROIstats -mask $(dirname $i)/$(basename ${i} _neuroharmonized.nii)_mask_01.nii -quiet $(dirname $i)/$(basename ${i} .nii)_z.nii > "$output_file"
    fi
done