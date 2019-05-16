# -*- coding: utf-8 -*-

"""
Prepare brain mask for pRF analysis.

The brain mask is created based on an intesity threshold applied to the mean
EPI image followed by a cluster size threshold and morphological operations
(dilation and closing).

(C) Ingo Marquardt, 2018
"""


# *****************************************************************************
# *** Import modules

import os
import numpy as np
import nibabel as nib
from skimage import morphology as skimrp
from skimage.measure import label
# *****************************************************************************


# *****************************************************************************
# *** Define parameters

# Load environmental variables defining the input data path:
pacman_data_path = str(os.environ['pacman_data_path'])
pacman_sub_id = str(os.environ['pacman_sub_id'])

# Path & filename of combined mean image:
strPthCombMean = (pacman_data_path
                  + pacman_sub_id
                  + '/nii/func_reg_tsnr/')
strCombMean = 'combined_mean.nii.gz'

# Path & filename of output (binary brain mask):
strPathOut = (pacman_data_path
              + pacman_sub_id
              + '/nii/retinotopy/mask/')
strMsk = 'brainmask.nii.gz'

# Intensity threshold:
varIntThr = 5000.0

# Cluster size threshold:
varCluSzeThr = 100000
# *****************************************************************************


# *****************************************************************************
# *** Preparations

print('-Preparing pRF fitting')

print('---Loading data')

# Load the nii file (this doesn't load the data into memory yet):
niiIn = nib.load((strPthCombMean + strCombMean))

# Load the data into memory:
aryData = niiIn.get_data()
aryData = np.array(aryData).astype(np.float32)
# *****************************************************************************


# *****************************************************************************
# *** Create mask

print('---Creating mask')

# Apply intensity threshold:
aryMsk = np.greater_equal(aryData, float(varIntThr))

# Find connected clusters

# Create labelled clusters:
aryLbls = label(aryMsk, connectivity=2)

# Vectors of cluster labels & number of voxels in each cluster:
vecLbls, vecCnt = np.unique(aryLbls, return_counts=True)

# Labels and label indicies of same data type:
aryLbls = aryLbls.astype(np.int64)
vecLbls = vecLbls.astype(np.int64)

# Applying connected clusters threshold:
for idxClst in vecLbls:
    if np.less(vecCnt[idxClst], varCluSzeThr):
        aryLbls[aryLbls == idxClst] = 0
aryLbls[aryLbls != 0] = 1

# Perform morphological operation (dilation followed by closing operation):
aryLbls = skimrp.binary_dilation(aryLbls)
aryLbls = skimrp.binary_dilation(aryLbls)
aryLbls = skimrp.binary_erosion(aryLbls)
# *****************************************************************************


# *****************************************************************************
# *** Save results

print('---Saving results')

# Create output nii object:
niiOt = nib.Nifti1Image(aryLbls,
                        niiIn.affine,
                        header=niiIn.header)

# Save image:
nib.save(niiOt, (strPathOut + strMsk))
# *****************************************************************************
