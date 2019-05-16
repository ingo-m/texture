"""Utility functions."""

# Part of the Segmentator library
# See https://github.com/ofgulban/segmentator/tree/devel/segmentator/utils.py
# Copyright (C) 2016  Omer Faruk Gulban and Marian Schneider
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import numpy as np  #noqa
import nibabel as nb


def load_nii(strPathIn, varSzeThr=1000.0):
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
              + str(varNiiSze)
              + ' MB), reading volume-by-volume'))

        # Get image dimensions:
        tplSze = objNii.shape

        # Create empty array for nii data:
        aryNii = np.zeros(tplSze, dtype=np.float16)

        # Loop through volumes:
        for idxVol in range(tplSze[3]):
            aryNii[..., idxVol] = np.asarray(
                  objNii.dataobj[..., idxVol]).astype(np.float16)

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
