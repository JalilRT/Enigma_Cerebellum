#!bin/bash

sb=$1
DB=$2
mkdir -p enigma/freesurfer/${sb}-back/
mkdir -p enigma/acapulco/output/ya/${sb}-back/
mv enigma/freesurfer/${sb}-back/*${DB}* enigma/freesurfer/${sb}/
mv enigma/acapulco/output/ya/${sb}-back/*${DB}* enigma/acapulco/output/ya/${sb}/
