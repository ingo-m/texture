# -*- coding: utf-8 -*-
"""
Convert event-related time course vtk meshes to npy format.

The collection of single-volume vtk meshes is converted into a single npy
format for faster access and to conserve disk space.
"""

# Part of py_depthsampling library
# Copyright (C) 2018  Ingo Marquardt
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.


import os
from os import listdir
import numpy as np
from loadVtkMulti import funcLoadVtkMulti


# *****************************************************************************
# *** Parameters

# Load environmental variables defining the input data path:
pacman_data_path = str(os.environ['pacman_data_path'])
pacman_sub_id = str(os.environ['pacman_sub_id'])

# List of directories with vtk files to be converted:
lstDir = [(pacman_data_path + pacman_sub_id + '/cbs/lh_era/bright_square'),
          (pacman_data_path + pacman_sub_id + '/cbs/lh_era/full_screen'),
          (pacman_data_path + pacman_sub_id + '/cbs/rh_era/bright_square'),
          (pacman_data_path + pacman_sub_id + '/cbs/rh_era/full_screen')]

# Number of cortical depths:
varNumDpth = 11

# Beginning of string which precedes vertex data in data vtk files (i.e. in the
# statistical maps):
strPrcdData = 'SCALARS'

# Number of lines between vertex-identification-string and first data point:
varNumLne = 2
# *****************************************************************************


# *****************************************************************************
# *** Convert vtk files to npy files

print('----------------------------------------------------------------------')

print('-vtk to npy conversion')

# Loop through target directories:
for strDirTmp in lstDir:

    print(('--Target directory: ' + strDirTmp))

    # Condition name (needed for file names):
    strCondTmp = os.path.split(strDirTmp)[1]

    # Get list of files in target directory:
    lstFls = listdir(strDirTmp)

    # Ignore files that do not have vtk file extension:
    lstFls = [f for f in lstFls if '.vtk' in f]

    # Sort files:
    lstFls = sorted(lstFls)

    # Number of volumes:
    varNumVol = len(lstFls)

    # Loop through volumes (i.e. through 3D vtk files):
    for idxVol in range(0, varNumVol):

        print(('---Volume: ' + str(idxVol)))

        # Path of current vtk file:
        strPthVtkTmp = os.path.join(strDirTmp, lstFls[idxVol])

        # Load vtk mesh for current timepoint:
        aryTmp = funcLoadVtkMulti(strPthVtkTmp,
                                  strPrcdData,
                                  varNumLne,
                                  varNumDpth).astype(np.float32)

        # Get number of vertices for first volume (has to be equal across
        # volumes) and preallocate np array:
        if idxVol == 0:

            # Number of vertices:
            varNumVrtc = aryTmp.shape[0]

            # Array to be filled with data:
            aryErt = np.zeros((varNumDpth, varNumVol, varNumVrtc),
                              dtype=np.float32)

        # Put current volume into array:
        aryErt[:, idxVol, :] = aryTmp.T

        # Delete vtk file:
        os.remove(strPthVtkTmp)

    # Save array to disk:
    strPthNpy = os.path.join(strDirTmp, ('aryErt_' + strCondTmp + '.npy'))
    print(('--Saving to disk: ' + strPthNpy))
    np.save(strPthNpy, aryErt)
# *****************************************************************************

print('--Done.')
