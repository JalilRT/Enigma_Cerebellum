#!bin/bash

module load apptainer
module load afni-Rlibs

path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_matchid
scripts_path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/scripts
cp $scripts_path/SUIT.nii $path/SUIT.nii

3dcalc -a $path/SUIT.nii -expr 'step(a)' -prefix $path/SUIT_mask.nii.gz

cd $path

for i in ATS; do

        mkdir -p ${i}/uncorrected_05/${i}_HC/
        # mkdir -p Clusterize_maps/uncorrected_05/${i}_HC_ges/

        # Clusterize in binary the voxels that are significant at p<0.05 (FDR corrected)
        if [ ! -f ${i}/Model_${i}_clust.nii.gz ]; then
            3dClusterize \
                -inset $path/${i}/Model_${i}.nii.gz \
                -mask $path/SUIT_mask.nii.gz \
                -ithr 1 -NN 1 \
                -bisided -1.9 1.9 \
                -clust_nvox ${path}/${i}/Model_${i}.CSimA.NN1_bisided.1D \
                -pref_map ${path}/${i}/uncorrected_05/${i}_HC/${i}_ttest_clust_reset_map.nii.gz \
                -idat 1 \
                -pref_dat ${path}/${i}/uncorrected_05/${i}_HC/${i}_ttest_clust_reset_dat.nii.gz
        else
            echo "${i}/Model_${i}_clust.nii.gz exists, skipping."
        fi

        # Calculate the Cohen's d map through the formula: t/sqrt(df) by using 3dcalc over the olay_clust_reset_dat.nii files
        # if [ ! -f ${i}/uncorrected_05/${i}_HC/${i}_effect_size.nii.gz ]; then
        #         df=2 # Degrees of freedom, adjust as necessary
        #         3dcalc -a "${i}/Model_${i}.nii.gz[5]" -expr "a/sqrt(${df})" -prefix ${i}/uncorrected_05/${i}_HC/${i}_effect_size.nii.gz
        # else
        #         echo "Cohen's d map for ${i} already exists. Skipping 3dcalc."
        # fi
        
done