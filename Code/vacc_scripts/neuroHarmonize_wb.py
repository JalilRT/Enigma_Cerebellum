# from neuroHarmonize import harmonizationLearn
import pandas as pd
import numpy as np
from neuroHarmonize.harmonizationNIFTI import flattenNIFTIs
from neuroHarmonize.harmonizationNIFTI import applyModelNIFTIs
from neuroHarmonize.harmonizationNIFTI import createMaskNIFTI
from neuroHarmonize.harmonizationLearn import harmonizationLearn
from neuroHarmonize.harmonizationLearn import saveHarmonizationModel
from neuroHarmonize.harmonizationApply import loadHarmonizationModel
import nibabel as nib
import sys

substance = sys.argv[1]

covars = pd.read_csv(f'scripts/match_id/{substance}/database_age_sex_etiv_{substance}.csv')
nifti_list = pd.read_csv(f'scripts/match_id/{substance}/input_files_mul_{substance}.csv')
path = f'/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/enigma/harmonized/{substance}'

nifti_avg, nifti_mask, affine, hdr0 = createMaskNIFTI(
    nifti_list, 
    threshold=0.2, 
    output_path=f'{path}/thresholded_mask.nii.gz'
)
nifti_array = flattenNIFTIs(nifti_list, f'{path}/thresholded_mask.nii.gz')

my_model, nifti_array_adj, s_data = harmonizationLearn(nifti_array, covars, return_s_data=True)#, smooth_terms=['AGE']
saveHarmonizationModel(my_model, f'{path}/my_model')

my_model = loadHarmonizationModel(f'{path}/my_model')

applyModelNIFTIs(covars, my_model, nifti_list, f'{path}/thresholded_mask.nii.gz')