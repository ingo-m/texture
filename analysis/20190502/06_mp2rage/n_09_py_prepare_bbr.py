# -*- coding: utf-8 -*-

"""
Prepare BBR.

The purpose of this script is to prepare boundary based registration. Relevant
files are copied, a wm masked is created, opening operation applied, and the
mask is dilated.
(C) Ingo Marquardt, 2017
"""


# *****************************************************************************
# *** Import modules

import os
import numpy as np
import nibabel as nib
from skimage import morphology as skimrp
from skimage.measure import label
from shutil import copyfile
# *****************************************************************************


# *****************************************************************************
# *** Define parameters

# Load environmental variables defining the input data path:
pacman_data_path = str(os.environ['pacman_data_path'])
pacman_sub_id = str(os.environ['pacman_sub_id'])

# Path & filename of combined mean image:
strPthCombMean = (pacman_data_path
                  + pacman_sub_id
                  + '/nii/mp2rage/03_reg/01_in/')
strCombMean = 'combined_mean'

# Path & filenames of mp2rage images:
strPathIn = (pacman_data_path
             + pacman_sub_id
             + '/nii/mp2rage/03_reg/04_reg/01_in/')
strT1 = 'mp2rage_t1'
strInv2 = 'mp2rage_inv2'
strPdw = 'mp2rage_pdw'
strT1w = 'mp2rage_uni'

# BBR directory I (BBR input files):
strPthBbr01 = (pacman_data_path
               + pacman_sub_id
               + '/nii/mp2rage/03_reg/04_reg/01_in/')

# BBR directory II (brainmask):
strPthBbr02 = (pacman_data_path
               + pacman_sub_id
               + '/nii/mp2rage/03_reg/04_reg/02_bbr_prep/')

# Cluster size threshold:
varCluSzeThr = 200
# *****************************************************************************


# *****************************************************************************
# Copy files

print('-Prepare BBR')

print('---Copying files')

copyfile((strPthCombMean + strCombMean + '.nii.gz'),
         (strPthBbr01 + strCombMean + '.nii.gz'))
# *****************************************************************************


# *****************************************************************************
# Create brain mask for BBR

print('---Creating brain mask for BBR')

# We would like to create a very conservative brain mask - a dilated WM mask.
# The following steps are performed:
# (1) Threshold the T1 image at an intensity of 1000
# (2) Run FSL FAST
# (3) Binarise FAST WM estimation
# (4) Perform opening operation on WM estimation
# (5) Apply cluster size threshold
# (6) Dilate WM mask

# (1) Threshold the T1 image at an intensity of 1000
print('------Threshold the T1 image')
strBshCmd = ('fslmaths ' + strPthBbr01 + strT1 + ' -thr 1000 ' + strPthBbr02
             + strT1 + '_thr')
os.system(strBshCmd)

# (2) Run FSL FAST
print('------Running FSL FAST')
strBshCmd = ('/usr/share/fsl/5.0/bin/fast '
             + '-t 1 -n 3 -H 0.1 -I 4 -l 20.0 -g -B -b -o '
             + strPthBbr02 + 'ch01_cl03 '
             + strPthBbr02 + strT1 + '_thr')
os.system(strBshCmd)

# (3) Binarise FAST WM estimation
print('------Binarising FAST WM estimation')
strBshCmd = ('fslmaths ' + strPthBbr02 + 'ch01_cl03_seg_0' + ' -bin '
             + strPthBbr02 + 'bbrmask')
os.system(strBshCmd)

# (4) Perform opening operation on WM estimation
print('------Opening operation')

# Load the nii file (this doesn't load the data into memory though):
niiIn = nib.load((strPthBbr02 + 'bbrmask.nii.gz'))
# Load the data into memory:
aryData = niiIn.get_data()
aryData = np.array(aryData)

# Perform opening:
aryData = skimrp.binary_opening(aryData)

# (5) Apply cluster size threshold
print('------Apply cluster size threshold')

# Find connected clusters

# Create labelled clusters:
aryData = label(aryData, connectivity=2)

# Vectors of cluster labels & number of voxels in each cluster:
vecLbls, vecCnt = np.unique(aryData, return_counts=True)

# Labels and label indicies of same data type:
aryData = aryData.astype(np.int64)
vecLbls = vecLbls.astype(np.int64)

# Applying connected clusters threshold:
for idxClst in vecLbls:
    if np.less(vecCnt[idxClst], varCluSzeThr):
        aryData[aryData == idxClst] = 0
aryData[aryData != 0] = 1

# (6) Dilate WM mask
print('------Dilating WM mask')
aryData = skimrp.binary_dilation(aryData)
aryData = skimrp.binary_dilation(aryData)
aryData = skimrp.binary_dilation(aryData)
aryData = skimrp.binary_dilation(aryData)
aryData = skimrp.binary_dilation(aryData)

# Save mask:

# Create output nii object:
niiOt = nib.Nifti1Image(aryData,
                        niiIn.affine,
                        header=niiIn.header)
# Save image:
nib.save(niiOt, (strPthBbr02 + 'bbrmask.nii.gz'))
# *****************************************************************************
