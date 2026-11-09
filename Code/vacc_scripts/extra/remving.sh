#!bin/bash

sb=$1
DB=$2
rm -r enigma/freesurfer/${sb}-back/*${DB}*
rm -r enigma/acapulco/output/ya/${sb}-back/*${DB}*
