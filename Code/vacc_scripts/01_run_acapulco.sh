#!/bin/bash
pwd; hostname; date

module load singularity/3.7.1
## Inputs
path=$(pwd)/enigma
container=$(pwd)/singularity_files/acapulco-0.2.1.sif
input=${path}/input
output=${path}/acapulco/output

echo "creating folder for each subject name in outputs"
echo ""
echo "which substance want to run? p.e. alcohol = ALC"
read substance
ls -d ${input}/${substance}*.nii.gz >> ${substance}-subject_list.txt
mv ${substance}-subject_list.txt ${path}/acapulco
#cd ${path}/acapulco 

for file in $(cat ${path}/acapulco/${substance}-subject_list.txt); do
subj=$(basename $file .nii.gz)
mkdir -p ${output}/${substance}/${subj}
#cp $file output/${subj}/
echo ""
echo ""
echo "Running Acapulco with subject: ${subj}"
singularity run -B $PWD:/$PWD $container -i $file -o ${output}/${substance}/${subj}
done
