#!/bin/bash

su=$1
for id in $(cat ${su}-subj.txt); do
mv $PWD/enigma/input/FS_ya/${su}/${id}* $PWD/enigma/input/
rm -r $PWD/enigma/freesurfer/${su}/${id}*
rm -r $PWD/enigma/acapulco/output/ya/${su}/${id}*
done
