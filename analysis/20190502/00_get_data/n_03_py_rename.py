# -*- coding: utf-8 -*-
"""
Rename nii images (remove `_e1` suffix).

The dicom to nii conversion tool (dcm2niix) sometime appends a suffix (`_e1`)
to nii files. It does not seem to be possible to disable this, and it is not
clear under which circumstances the suffix is added. Thus, it has to be
removed.
"""

# Part of LGN pRF analysis pipeline.
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
from os.path import isfile, join

# Load environmental variables defining the input data path:
strDataPth = str(os.environ['pacman_data_path'])
strSubId = str(os.environ['pacman_sub_id'])

# Full directory, e.g. '/media/sf_D_DRIVE/MRI_Data_PhD/08_lgn_prf/
# derivatives/sub-01/raw_data/ses-01/':
strPathIn = (strDataPth
             + strSubId
             + '/nii/raw_data/')

# Get list of files in results directory:
lstFls = [f for f in os.listdir(strPathIn) if isfile(join(strPathIn, f))]

# Rename nii files with '_e1' suffix:
for strTmp in lstFls:
    if '_e1.' in strTmp:

        # Split into file path+name (without '_e1') and suffix (e.g.
        # 'nii.gz').
        strPth, strSuff = tuple(strTmp.split('_e1.'))

        # Rename file:
        os.rename((strPathIn + strTmp),
                  (strPathIn + strPth + '.' + strSuff))
