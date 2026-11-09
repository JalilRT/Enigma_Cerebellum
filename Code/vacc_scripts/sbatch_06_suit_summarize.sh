#!/bin/bash
#SBATCH --job-name=suit_job
#SBATCH --mem-per-cpu=10G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --error=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/Suitjob.%J.err
#SBATCH --output=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/Suitjob.%J.out

set -e

pwd; hostname; date
module load matlab/R2023b

substance=$1
DB=$2
cd /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info
path=$(pwd)
acapulco_path=${path}/enigma/acapulco/output/ya
mkdir -p ${path}/enigma/suit/${substance}
suit_path=${path}/enigma/suit/${substance}

ls -d $PWD/enigma/suit/${substance}/${DB}* > $PWD/enigma/suit/listP_${DB}.txt

export WORKING_DIR=${acapulco_path}
export SUBJECT_LIST=$PWD/enigma/suit/listP_${DB}.txt
export OUTPUT_DIR=${suit_path}
export SUIT_DIR=${path}/singularity_files

cd $WORKING_DIR
cat $SUBJECT_LIST |  while read dir; do
echo cd $dir
cd $dir
i=$(basename $dir)

matlab -nodisplay -nosplash -r "addpath('${WORKING_DIR}'),addpath(genpath('${SUIT_DIR}/spm12')),addpath('${SUIT_DIR}/suit-3.5'),addpath('${SUIT_DIR}/enigma_suit'),addpath('${OUTPUT_DIR}'),suit_ROI_summarize(['iw_atl-MDTB10_space-SUIT_dseg_u_a_','$i','_n4_mni_seg1.nii'],'atlas',['$path','/singularity_files/cerebellar_atlases/King_2019/atl-MDTB10_space-SUIT_dseg.nii'],'outfilename',['$i','.txt']),exit"
done

rm ${path}/enigma/suit/listP_${DB}.txt

#suit_ROI_summarize(['iw_atl-MDTB10_space-SUIT_dseg_u_a_','$i','_n4_mni_seg1.nii'],'atlas',['$path','/singularity_files/cerebellar_atlases/King_2019/atl-MDTB10_space-SUIT_dseg.nii'])
