#!bin/bash

substance=$1
database=$2

for i in $(ls -d $PWD/enigma/input/FS_ya/${substance}/*${database}*); do 
  basename $i | cut -d "_" -f2 >> subjects_list/${substance}_input.txt
done

for i in $(ls -d $PWD/enigma/acapulco/output/ya/${substance}/*${database}*); do
  basename $i | cut -d "_" >> subjects_list/${substance}_acapulco.txt
done

for i in $(ls -d $PWD/enigma/freesurfer/${substance}/*${database}*); do
  basename $i >> subjects_list/${substance}_freesurfer.txt
done

echo "ran freesurfer, not acapulco"
grep -Fxvf subjects_list/${substance}_acapulco.txt subjects_list/${substance}_freesurfer.txt

echo ""

echo "ran acapulco, not freesurfer"
grep -Fxvf subjects_list/${substance}_freesurfer.txt subjects_list/${substance}_acapulco.txt
echo ""

echo "inputs"
grep -Fxvf subjects_list/${substance}_ic.txt subjects_list/${substance}_acapulco.txt

echo ""

