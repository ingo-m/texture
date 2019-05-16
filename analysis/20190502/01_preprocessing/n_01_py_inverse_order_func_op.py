"""
Inverse opposite-phase-polarity images for motion correction to last volume.

The purpose of this script is to change the temporal order of volumes in a 4D
nii file. This script may be used when opposite-phase-encode direction data is
to be motion corrected with SPM, and the reference volume is supposed to be the
last volume in the time series (because the images are supposed to be in good
registry with the following run). Since the last volume cannot be selected as
the reference volume in SPM, one has to change the order to volumes, as a
workaround.

(C) Ingo Marquardt, 2017
"""


# *****************************************************************************
# *** Import modules

import os
import numpy as np  #noqa
import nibabel as nib
# *****************************************************************************


# *****************************************************************************
# *** Define parameters

# Load environmental variables defining the input data path:
pacman_data_path = str(os.environ['pacman_data_path'])
pacman_sub_id = str(os.environ['pacman_sub_id'])

# Path to images to be swapped:
lstPathIn = [(pacman_data_path
              + pacman_sub_id
              + '/nii/func_se_op/func_00.nii.gz')]

# Output file paths:
lstPathOt = [(pacman_data_path
              + pacman_sub_id
              + '/nii/func_se_op_inv/func_00.nii.gz')]
# *****************************************************************************


# *****************************************************************************
# ***  Define functions

def fncLoadNii(strPathIn):
    """Load nii files."""
    print(('------Loading: ' + strPathIn))

    # Load nii file (this doesn't load the data into memory yet):
    niiTmp = nib.load(strPathIn)

    # Load data into array:
    aryTmp = niiTmp.get_data()

    # Get headers:
    hdrTmp = niiTmp.header

    # Get 'affine':
    aryAff = niiTmp.affine

    # Output nii data as numpy array and header:
    return aryTmp, hdrTmp, aryAff
# *****************************************************************************


# *****************************************************************************
# *** Perform correction

print('-Swap temporal order of volumes in 4D nii file.')

print('---Performing correction')

# Loop through input files:

for idxIn in range(0, len(lstPathIn)):

    # print('------File: ' + lstPathIn[idxIn])

    # Load the nii file:
    aryData, hdrNii, aryAff = fncLoadNii(lstPathIn[idxIn])

    # Reverse the order of the array elements along the fourth dimenstion
    # (i.e. time):
    aryData = aryData[:, :, :, ::-1]

    # Create new nii image:
    niiOut = nib.Nifti1Image(aryData,
                             aryAff,
                             header=hdrNii)

    # Save correctedimage:
    nib.save(niiOut,
             lstPathOt[idxIn])

    # Delete original file:
    # os.remove(lstPathIn[idxIn])

print('---Done.')
# *****************************************************************************
