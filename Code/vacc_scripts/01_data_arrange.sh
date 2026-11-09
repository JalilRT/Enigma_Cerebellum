
#!/bin/bash

path=$(pwd)
ls ${path}/Data_with_MRI_info/
echo 'Which folder want you arrange?'
read folder
Data_files=${path}/Data_with_MRI_info/$folder
ls $Data_files

echo ""
echo "In which position is the subject number in terms of '_'? (p.e. qwerty_42_qwerty.nii.gz)"
read num

echo "#################### Arranging the data files ####################"

for file in $(ls -d $Data_files/*); do
  number=$(basename $file | cut -d "-" -f $num)
  #echo $number
  cp $file ${path}/data_arranged/${folder}_sub-${number}_T1w.nii.gz
done
