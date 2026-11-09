#!bin/bash

sb=$1
DB=$2
mkdir -p enigma/freesurfer/${sb}-back/
mkdir -p enigma/acapulco/output/ya/${sb}-back/
mv enigma/freesurfer/${sb}/*${DB}* enigma/freesurfer/${sb}-back/
mv enigma/acapulco/output/ya/${sb}/*${DB}* enigma/acapulco/output/ya/${sb}-back/ 
