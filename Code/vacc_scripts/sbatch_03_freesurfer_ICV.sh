#!/bin/bash
#SBATCH --job-name=ICV_job
#SBATCH --mem-per-cpu=10G
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --error=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/FSjob.%J.err
#SBATCH --output=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/FSjob.%J.out

pwd; hostname; date

module load singularity/3.7.1

## Inputs
path=$(pwd)/enigma
container=$(pwd)/singularity_files/FS7.sif
input=${path}/input/ya
output=${path}/freesurfer

export SINGULARITYENV_FS_LICENSE=$(pwd)/singularity_files/license.txt
export SINGULARITYENV_SUBJECTS_DIR=$(pwd)/enigma/freesurfer/

substance=$1
echo "running $substance"
ls -d ${input}/${substance}*.nii.gz >> ${substance}-subject_listFS.txt
mv ${substance}-subject_listFS.txt ${path}/acapulco
#cd ${path}/acapulco

for file in $(cat ${path}/acapulco/${substance}-subject_listFS.txt); do
subj=$(basename $file .nii.gz)
#mkdir -p ${output}/${substance}/${subj}
echo ""
echo "Running autorecon1 with subject: ${subj}"
#srun --mem-per-cpu=10G --export=SINGULARITYENV_FS_LICENSE=$(pwd)/singularity_files/license.txt \
# --export=SINGULARITYENV_SUBJECTS_DIR=$(pwd)/enigma/freesurfer/ \
singularity exec -B $PWD:/$PWD $container recon-all -i $file -s $subj -autorecon1
mv $file ${path}/input/FS_ya/

done

rm ${path}/acapulco/${substance}-subject_listFS.txt
