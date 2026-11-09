#!bin/bash

database=$1

for i in $(ls -d $PWD/enigma/input/FS_ya/ALC/${database}_sub-*); do 
  basename $i | cut -d "_" -f2 >> subjects_list/${database}_vacc.txt
done

echo "is in vacc"
grep -Fxvf subjects_list/${database}.txt subjects_list/${database}_vacc.txt

echo ""

echo "is in excel, not in vacc"
grep -Fxvf subjects_list/${database}_vacc.txt subjects_list/${database}.txt
