# -*- coding: utf-8 -*-
"""
Deface MP2RAGE images and correct truncation error in T1 image.

MP2RAGE images are anonymised (i.e. 'defaced') by setting anterior voxels to
zero. Additionally, truncation errors in the T1 image are removed (high
intensity voxels have a value of zero in these images, probably due to a bug
in the reconstruction software). These voxels are set to the maximum value in
the images.
"""

# Part of PacMan analysis pipeline.
# Copyright (C) 2018  Ingo Marquardt
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import numpy as np
import nibabel as nb

# ------------------------------------------------------------------------------
# ### Function definitions


def load_nii(strPathIn, varSzeThr=5000.0):
    """
    Load nii file.

    Parameters
    ----------
    strPathIn : str
        Path to nii file to load.
    varSzeThr : float
        If the nii file is larger than this threshold (in MB), the file is
        loaded volume-by-volume in order to prevent memory overflow. Default
        threshold is 1000 MB.

    Returns
    -------
    aryNii : np.array
        Array containing nii data. 32 bit floating point precision.
    objHdr : header object
        Header of nii file.
    aryAff : np.array
        Array containing 'affine', i.e. information about spatial positioning
        of nii data.

    Notes
    -----
    If the nii file is larger than the specified threshold (`varSzeThr`), the
    file is loaded volume-by-volume in order to prevent memory overflow. The
    reason for this is that nibabel imports data at float64 precision, which
    can lead to a memory overflow even for relatively small files.
    """
    # Load nii file (this does not load the data into memory yet):
    objNii = nb.load(strPathIn)

    # Get size of nii file:
    varNiiSze = os.path.getsize(strPathIn)

    # Convert to MB:
    varNiiSze = np.divide(float(varNiiSze), 1000000.0)

    # Load volume-by-volume or all at once, depending on file size:
    if np.greater(varNiiSze, float(varSzeThr)):

        # Load large nii file

        print(('---------Large file size ('
              + str(np.around(varNiiSze))
              + ' MB), reading volume-by-volume'))

        # Get image dimensions:
        tplSze = objNii.shape

        # Create empty array for nii data:
        aryNii = np.zeros(tplSze, dtype=np.float32)

        # Loop through volumes:
        for idxVol in range(tplSze[3]):
            aryNii[..., idxVol] = np.asarray(
                  objNii.dataobj[..., idxVol]).astype(np.float32)

    else:

        # Load small nii file

        # Load nii file (this doesn't load the data into memory yet):
        objNii = nb.load(strPathIn)

        # Load data into array:
        aryNii = np.asarray(objNii.dataobj).astype(np.float32)

    # Get headers:
    objHdr = objNii.header

    # Get 'affine':
    aryAff = objNii.affine

    # Output nii data (as numpy array), header, and 'affine':
    return aryNii, objHdr, aryAff


# ------------------------------------------------------------------------------
# ### Deface MP2RAGE images

print('-Deface MP2RAGE images')

# Load environmental variables defining the input data path:
pacman_data_path = str(os.environ['pacman_data_path'])
pacman_sub_id_bids = str(os.environ['pacman_sub_id_bids'])

# Full input data path:
strPathIn = (pacman_data_path
             + 'BIDS/'
             + pacman_sub_id_bids
             + '/anat/')

# List of images to deface:
lstIn = ['mp2rage_inv1.nii.gz',
         'mp2rage_inv1_phase.nii.gz',
         'mp2rage_pdw.nii.gz',
         'mp2rage_pdw_phase.nii.gz',
         'mp2rage_t1.nii.gz',
         'mp2rage_uni.nii.gz']

# Loop through images:
for strImage in lstIn:

    # Complete path of image to load:
    strPthTmp = (strPathIn + strImage)

    print(('---Defacing: ' + strPthTmp))

    # Load image:
    aryNiiTmp, objHdrTmp, aryAffTmp = load_nii(strPthTmp)

    # Set anterior voxels to zero:
    aryNiiTmp[:, 250:, :] = 0.0

    # Create output nii object:
    niiOut = nb.Nifti1Image(aryNiiTmp,
                            aryAffTmp,
                            header=objHdrTmp
                            )
    # Save nii:
    nb.save(niiOut, strPthTmp)
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# ### Correct truncation errors in T1 image

print('-Correct truncation errors in T1 image')

# Load environmental variables defining the input data path:
# pacman_data_path = str(os.environ['pacman_data_path'])
# pacman_sub_id_bids = str(os.environ['pacman_sub_id_bids'])

# Full input data path:
# strPathIn = (pacman_data_path
#              + 'BIDS/'
#              + pacman_sub_id_bids
#              + '/anat/')

# List of images to deface:
lstIn = ['mp2rage_inv1.nii.gz',
         'mp2rage_inv1_phase.nii.gz',
         'mp2rage_pdw.nii.gz',
         'mp2rage_pdw_phase.nii.gz',
         'mp2rage_t1.nii.gz',
         'mp2rage_uni.nii.gz']

# Complete paths of images to load:
strPthT1 = (strPathIn + 'mp2rage_t1.nii.gz')
strPthPdw = (strPathIn + 'mp2rage_pdw.nii.gz')

# Load images:
aryNiiT1, objHdrT1, aryAffT1 = load_nii(strPthT1)
aryNiiPwd, _, _ = load_nii(strPthPdw)

# Minimum and maximum in T1 image:
varMin = np.amin(aryNiiT1)
varMax = np.amax(aryNiiT1)

# Find voxels that are minimum (zero) in the T1 image, but not in the PDw
# image, and set them to max:
aryLgc01 = np.equal(aryNiiT1, varMin)
aryLgc02 = np.not_equal(aryNiiPwd, varMin)
aryLgc03 = np.logical_and(aryLgc01, aryLgc02)
aryNiiT1[aryLgc03] = varMax

# Create output nii object:
niiT1Out = nb.Nifti1Image(aryNiiT1,
                          aryAffT1,
                          header=objHdrT1
                          )
# Save nii:
nb.save(niiT1Out, strPthT1)
# ------------------------------------------------------------------------------
