#!/bin/bash
#SBATCH --job-name=AR_%J
#SBATCH --time=30:00:00
#SBATCH --error=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/AuFSjob.%J.err
#SBATCH --output=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/AuFSjob.%J.out

pwd; hostname; date

module load singularity/3.7.1

## Inputs
substance=$1
drug=$2
path=$(pwd)/enigma
container=$(pwd)/singularity_files/FS7.sif
input=${path}/input/ya
output=${path}/freesurfer/${drug}

export SINGULARITYENV_FS_LICENSE=$(pwd)/singularity_files/license.txt
export SINGULARITYENV_SUBJECTS_DIR=${output}

echo "running $substance"
rm ${path}/acapulco/${substance}-subject_listFS.txt
ls -d ${output}/${substance}*/ >> ${substance}-subject_listFS.txt
mv ${substance}-subject_listFS.txt ${path}/acapulco

grep -vxFf ${path}/FS_${substance}.txt ${path}/acapulco/${substance}-subject_listFS.txt > ${path}/acapulco/${substance}-subject_listFS2.txt

rm ${path}/acapulco/${substance}-subject_listFS.txt
mv ${path}/acapulco/${substance}-subject_listFS2.txt ${path}/acapulco/${substance}-subject_listFS.txt

for file in $(cat ${path}/acapulco/${substance}-subject_listFS.txt); do
subj=$(basename $file .nii.gz)
echo ""
echo "Running autorecon2 and 3 with subject: ${subj}"
singularity exec -B $PWD:/$PWD $container recon-all -s $subj -autorecon2 -autorecon3 -no-isrunning
echo "${output}/${subj}/" >> ${path}/FS_${substance}.txt

done

#rm ${path}/acapulco/${substance}-subject_listFS.txt
