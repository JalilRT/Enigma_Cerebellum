#!/bin/bash
#SBATCH --job-name=AR_%J
#SBATCH --time=30:00:00
#SBATCH --error=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/AuFSjob.%J.err
#SBATCH --output=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/AuFSjob.%J.out

pwd; hostname; date

module load singularity/3.7.1

## Inputs
substance=$1
path=$(pwd)/enigma
container=$(pwd)/singularity_files/FS7.sif
input=${path}/input/ya

export SINGULARITYENV_FS_LICENSE=$(pwd)/singularity_files/license.txt

for file in $(cat $(pwd)/${substance}_runFS.txt); do
drug=${substance}
subj=${file}
output=${path}/freesurfer/${drug}
export SINGULARITYENV_SUBJECTS_DIR=${output}
echo ""
echo "Running autorecon2 and 3 with subject: ${subj}"
singularity exec -B $PWD:/$PWD $container recon-all -s $subj -autorecon2 -autorecon3 -no-isrunning
sed '/${subj}/d' ${substance}_runFS.txt > temp.txt
rm ${substance}_runFS.txt                                                                                            
mv temp.txt ${substance}_runFS.txt  

done

#rm ${path}/acapulco/${substance}-subject_listFS.txt
