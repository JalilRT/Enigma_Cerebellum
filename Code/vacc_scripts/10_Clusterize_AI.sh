#!bin/bash

module load apptainer
module load afni-full

path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI
scripts_path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/scripts
cp $scripts_path/SUIT.nii $path/SUIT.nii

cd $path

for i in USERS; do #ALC ATS CANN COC NIC OPI 

        file_N=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/models_AI/temp/${i}.txt
        N_sample=$(wc -l < "$file_N")

        cd ${i}
        mkdir -p uncorrected_05/${i}_HC/
        # mkdir -p Clusterize_maps/uncorrected_05/${i}_HC_ges/

        # Calculate the ACF parameters using 3dFWHMx
        if [ ! -f acf_params_${i}.txt ]; then
                3dFWHMx -input Model_${i}.nii.gz -acf > acf_params_${i}.txt
        else 
                echo "ACF parameters file for ${i} already exists. Skipping 3dFWHMx."
        fi

        # Extract the clust_nvox value from output by using 3dClustSim
        if [ ! -f Clustsim_${i}.txt ]; then
                3dClustSim -acf $(awk 'NR==2 {print $1, $2, $3}' acf_params_${i}.txt) -nodec > Clustsim_${i}.txt
        else
                echo "ClustSim output file for ${i} already exists. Skipping 3dClustSim."
        fi

        # Extract the clust_nvox value from clustSim output file with pthr=0.05 and -NN 1
        clust_nvox=$(awk -v pthr=0.002000 '/bi-sided thresholding/{flag=1;next}/^\s*$/{flag=0}flag {if ($1==pthr) {print $3; exit}}' Clustsim_${i}.txt)

        echo "Cluster size for p<0.05: ${clust_nvox} voxels"
        # If clust_nvox is empty, set a default value (e.g., 20)
        if [ -z "$clust_nvox" ]; then
        clust_nvox=20
        echo "No cluster size found for p<0.05, using default value: ${clust_nvox} voxels"
        fi

        if [ ! -f uncorrected_05/${i}_HC/__tmp_chauf_*/olay_clust_reset_dat.nii ]; then
                @chauffeur_afni -ulay ${path}/SUIT.nii -box_focus_slices AMASK_FOCUS_ULAY \
                        -olay Model_${i}.nii.gz -cbar Reds_and_Blues_Inv -ulay_range 0% 100% \
                        -func_range 3 -set_subbricks 0 5 5 -clusterize "-NN 1 -clust_nvox ${clust_nvox}" \
                        -thr_olay_p2stat 0.05 -thr_olay_pside bisided -olay_alpha Yes \
                        -olay_boxed Yes -opacity 2 -prefix uncorrected_05/${i}_HC/${i} \
                        -set_xhairs OFF -montx 4 -monty 4 -label_mode OFF -no_clean
        else
                echo "Output for ${i} already exists. Skipping @chauffeur_afni."
        fi

        # Calculate the Cohen's d map through the formula: 2*z/sqrt(N) by using 3dcalc over the olay_clust_reset_dat.nii files
        echo "Calculating Cohen's d map for ${i}..., with N = ${N_sample}"
        if [ ! -f uncorrected_05/${i}_HC/${i}_effect_size.nii.gz ]; then
                N=${N_sample}-1 # You need to set the appropriate sample size N here
                3dcalc -a uncorrected_05/${i}_HC/__tmp_chauf_*/olay_clust_reset_dat.nii \
                        -expr "2*a/sqrt(${N})" -prefix uncorrected_05/${i}_HC/${i}_effect_size.nii.gz
        else
                echo "Cohen's d map for ${i} already exists. Skipping 3dcalc."
        fi
        
        cd $path
done