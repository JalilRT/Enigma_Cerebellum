#!/bin/bash
#SBATCH --job-name=suit_job
#SBATCH --mem-per-cpu=10G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --error=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/Suitjob.%J.err
#SBATCH --output=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/Suitjob.%J.out

set -e

pwd; hostname; date
module load matlab/matlab2021a

substance=$1
cd /gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info
path=$(pwd)
acapulco_path=${path}/enigma/acapulco/output/ya
mkdir -p ${path}/enigma/suit/${substance}
suit_path=${path}/enigma/suit/${substance}

ls -d $PWD/enigma/acapulco/output/ya/${substance}/* > $PWD/enigma/suit/listP_${substance}.txt

export WORKING_DIR=${acapulco_path}
export SUBJECT_LIST=$PWD/enigma/suit/listP_${substance}.txt
export OUTPUT_DIR=${suit_path}
export SUIT_DIR=${path}/singularity_files

cd $WORKING_DIR
cat $SUBJECT_LIST |  while read i; do
matlab -nodisplay -nosplash -r "addpath('${WORKING_DIR}'),addpath('${SUIT_DIR}/spm12'),addpath('${SUIT_DIR}/suit-3.5'),addpath('${SUIT_DIR}/enigma_suit'),addpath('${OUTPUT_DIR}'),suit_enigma_all('$i','${OUTPUT_DIR}'),exit"
done

rm ${path}/enigma/suit/listP_${substance}.txt
