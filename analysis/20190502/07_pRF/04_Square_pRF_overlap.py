# -*- coding: utf-8 -*-

"""
Calculate retinotopic overlap.

The purpose of this script is to load nii files containing results from a
population receptive field mapping analysis, and to create new nii files
containing information about the overlap of the pRFs and a visual stimulus.
"""

# Part of Surface library
# Copyright (C) 2016  Ingo Marquardt
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

# *****************************************************************************
# *** Import modules
import os
import numpy as np
import nibabel as nib
import time
import multiprocessing as mp
# *****************************************************************************


print('-Stimulus-pRF overlap calculation')


# *****************************************************************************
# *** Define parameters

# Load environmental variables defining the input data path:
pacman_data_path = str(os.environ['pacman_data_path'])
pacman_sub_id = str(os.environ['pacman_sub_id'])

# Path of nii file with x-coordinates of pRFs:
strNiiX = (pacman_data_path
           + pacman_sub_id
           + '/nii/retinotopy/pRF_results_up/pRF_results_x_pos.nii.gz')

# Path of nii file with y-coordinates of pRFs:
strNiiY = (pacman_data_path
           + pacman_sub_id
           + '/nii/retinotopy/pRF_results_up/pRF_results_y_pos.nii.gz')

# Path of nii file with pRF size estimates (SD):
strNiiSd = (pacman_data_path
            + pacman_sub_id
            + '/nii/retinotopy/pRF_results_up/pRF_results_SD.nii.gz')

# Path of nii file with R2 values:
strNiiR2 = (pacman_data_path
            + pacman_sub_id
            + '/nii/retinotopy/pRF_results_up/pRF_results_R2.nii.gz')

# Output file base name:
strNiiOt = (pacman_data_path
            + pacman_sub_id
            + '/nii/retinotopy/pRF_results_up/pRF_results_')

# Define the area  of the visual field that was covered by the pRF mapping
# stimuli (this is the area of the visual field for which pRFs are defined) in
# degree of visual angle:
varXmin = -8.3
varXmax = 8.3
varXstep = 64.0
varYmin = -5.19
varYmax = 5.19
varYstep = 40.0

# Minimum pRF size in degree of visual angle:
varSdMin = 0.2

# In order to calculate the overlap between the visual stimulus and each
# voxel's receptive field more accurately, we supersample the visual stimulus
# space by the following factor (e.g., a factor of 10 means that if there were
# 40 sampling points along the x or y axis for the pRF fitting, we use
# 40 * 10 = 400 sampling points along this dimension for the calculation of the
# overlap):
varSupSmp = 5.0

# -----------------------------------------------------------------------------
# In the texture/uniform control experiment, the central square has slightly
# different dimensions than in the previous sessions of the surface experiment,
# in order to match the area of the PacMan stimulus. The edge length of the
# square in the texture/uniform control experiment is 2 * 3.325 (as opposed to
# (2 * 3 in the previous surface experiments). The dimensions of the ROIs are
# adjusted accordingly.
# -----------------------------------------------------------------------------

# Limits of central square ROI:
tplLimCntrX = (-2.325, 2.325)
tplLimCntrY = (-2.325, 2.325)

# Radius of central region to avoid (fixation dot):
varFix = 0.75

# Limits of border ROI (border is at 3.325 deg):
lstLimEdgX = [(-3.825, -2.825), (2.825, 3.825)]
lstLimEdgY = [(-3.825, -2.825), (2.825, 3.825)]

# Limits of background ROI:
lstLimBckX = [(-8.3, -5.0), (5.0, 8.3)]
lstLimBckY = [(-5.19, 5.19), (-5.19, 5.19)]

# Overlap is calculated with an R2 value above the following threshold:
varThrR = 0.1

# Overlap criteria. Voxels are included in the mask if the overlap between
# their population receptive fiel and the annulus is greater than or equal to
# this value [percent].
lstOvrlp = [50, 75, 90, 95]

# Number of processes to run in parallel:
varPar = 11
# *****************************************************************************


# *****************************************************************************
# ***  Check time
varTme01 = time.time()
# *****************************************************************************


# *****************************************************************************
# *** Define functions


def fncLoadNii(strPathIn):
    """Load nii files."""
    print(('---------Loading: ' + strPathIn))
    # Load nii file (this doesn't load the data into memory yet):
    niiTmp = nib.load(strPathIn)
    # Load data into array:
    aryTmp = niiTmp.get_data()
    # Get headers:
    hdrTmp = niiTmp.header
    # Get 'affine':
    niiAff = niiTmp.affine
    # Output nii data as numpy array and header:
    return aryTmp, hdrTmp, niiAff


def fncPrfOvrlp(idxPrc,
                aryNiiXChnk,
                aryNiiYChnk,
                aryNiiSdChnk,
                aryNiiR2Chnk,
                aryLgcStim,
                varXmin,
                varXmax,
                varXstep,
                varYmin,
                varYmax,
                varYstep,
                varSupSmp,
                vecXcords,
                vecYcords,
                varSdMin,
                varPar,
                queOut):
    """Calculate stimulus-pRF overlap."""
    # Number of voxels in this chunk of data:
    varNumVoxChnk = aryNiiXChnk.size

    # Array for result (overlap ratio) for this chunk of data:
    aryRatioChnk = np.zeros(varNumVoxChnk)

    # Array for result (pRF centre on stimulus?) for this chunk of data:
    aryCentreChnk = np.zeros(varNumVoxChnk)

    # Prepare status indicator if this is the first of the parallel processes:
    if idxPrc == 0:

        # Number of steps for the status indicator:
        varStsStpSze = 20

        # Vector with voxel indicies at which to give status feedback:
        vecStsStp = np.linspace(0,
                                varNumVoxChnk,
                                num=(varStsStpSze+1),
                                endpoint=True)
        vecStsStp = np.ceil(vecStsStp)
        vecStsStp = vecStsStp.astype(int)

        # Vector with corresponding percentage values at which to give status
        # feedback:
        vecStatPrc = np.linspace(0,
                                 100,
                                 num=(varStsStpSze+1),
                                 endpoint=True)
        vecStatPrc = np.ceil(vecStatPrc)
        vecStatPrc = vecStatPrc.astype(int)

        # Counter for status indicator:
        varCntSts01 = 0
        varCntSts02 = 0

    # Loop through voxels in input chunk:
    for idxVox in range(0, varNumVoxChnk):

        # Status indicator (only used in the first of the parallel processes):
        if idxPrc == 0:

            # Status indicator:
            if varCntSts02 == vecStsStp[varCntSts01]:

                # Prepare status message:
                strStsMsg = ('---------Progress: ' +
                             str(vecStatPrc[varCntSts01]) +
                             ' % --- ' +
                             str(int((vecStsStp[varCntSts01] * varPar))) +
                             ' voxels out of ' +
                             str(int(varNumVoxChnk) * varPar))

                print(strStsMsg)

                # Only increment counter if the last value has not been
                # reached yet:
                if varCntSts01 < varStsStpSze:
                    varCntSts01 = varCntSts01 + int(1)

        # Create meshgrid for Gaussian model:
        [aryTmpX, aryTmpY] = np.meshgrid(
            np.linspace(varXmin, varXmax, (varXstep * varSupSmp)),
            np.linspace(varYmin, varYmax, (varYstep * varSupSmp))
            )

        # Because of interpolation (e.g. during upsampling), it can happen that
        # some voxel have pRF models with a very small (and implausible) size.
        # This is expected to happen at the surface of the brain (where
        # interpolation between positive values within the brain and zeros
        # outside the brain takes place during upsampling or spatial
        # transformations). Therefore, we exclude voxels with a too low pRF
        # size.
        if varSdMin <= aryNiiSdChnk[idxVox]:

            # Create Gaussian pRF model:
            aryTmpGaus = np.divide((
                (aryTmpX - aryNiiXChnk[idxVox]) ** 2.0 +
                (aryTmpY - aryNiiYChnk[idxVox]) ** 2.0
                ),
                (2.0 * (aryNiiSdChnk[idxVox] ** 2.0))
                )

            aryTmpGaus = np.exp(-aryTmpGaus)

            # We calculate how much of the pRF area of the current voxel is
            # contained within the stimulus. We start by multipying the matrix
            # representing the pRF with the matrix representing the annulus:
            aryTmpOvrlp = aryTmpGaus * aryLgcStim

            # We calculate the ratio:
            aryRatioChnk[idxVox] = np.divide(np.sum(aryTmpOvrlp),
                                             np.sum(aryTmpGaus)) * 100.0

        else:

            # In case the size of the pRF model is too small to be plausible,
            # we set the overlap ratio to zero:
            aryRatioChnk[idxVox] = 0.0

        # We would like to create a binary map for pRF centre overlap with
        # stimulus (i.e. whether the pRF centre is on the stimulus). For that
        # we need to convert the position of the pRF model of the current voxel
        # from visual space coordinates into matrix indicies of the matrix
        # representing the stimulus. Start by getting the current voxel's pRF
        # centre position (in visual space):
        varTmpXcord = aryNiiXChnk[idxVox]
        varTmpYcord = aryNiiYChnk[idxVox]

        # The visual space model will likely not contain the exact same values
        # as the current pRF position (different upsampling may have been used
        # during pRF model finding than in this script). Therefore, we need to
        # find the index of the visual space coordinate closest to the current
        # pRF centre:
        varTmpXidx = np.argmin(np.absolute(vecXcords - varTmpXcord))
        varTmpYidx = np.argmin(np.absolute(vecYcords - varTmpYcord))

        # We put the value from the array representing the stimulus into the
        # binary overlap array. The array representing the stimulus contains
        # ones and zeros (stimulus at that location - yes/no), so we don't need
        # any additional logical test. Note that when indexing the stimulus
        # array the first index is for the y-position and the second index for
        # the x-position, because the y-positions are from top to bottom.
        aryCentreChnk[idxVox] = aryLgcStim[varTmpYidx, varTmpXidx]

        # Status indicator (only used in the first of the parallel processes):
        if idxPrc == 0:

            # Increment status indicator counter:
            varCntSts02 = varCntSts02 + 1

    # Prepare output list:
    lstOut = [idxPrc,
              aryRatioChnk,
              aryCentreChnk]

    queOut.put(lstOut)
# *****************************************************************************


# *****************************************************************************
# *** Preparations

print('---Preparations')

# Load nii files:
print('------Loading nii files')
aryNiiX, hdrNiiX, aryAffX = fncLoadNii(strNiiX)
aryNiiY, hdrNiiY, aryAffY = fncLoadNii(strNiiY)
aryNiiSd, hdrNiiSd, aryAffSd = fncLoadNii(strNiiSd)
aryNiiR2, hdrNiiR2, aryAffR2 = fncLoadNii(strNiiR2)

print('------Preparing arrays')

# Visual space in Cartesian coordinates:
[arySpaceXcrt, arySpaceYcrt] = np.meshgrid(
    np.linspace(varXmin, varXmax, int(varXstep * varSupSmp)),
    np.linspace(varYmin, varYmax, int(varYstep * varSupSmp)))

# Calculate the distance between each point in the visual space to the centre
# of the visual space ("If we want to find the distance between two points in
# a coordinate plane we use a formula that is based on the Pythagorean Theorem
# were (x1,y1) and (x2,y2) are the coordinates and d marks the distance:
# d = sqrt( (x2 - x1)^2 + (y2 - y1)^2 "
# Source:
#   http://www.mathplanet.com/education/geometry/points,-lines,-planes-and-
#   angles/finding-distances-and-midpoints).
aryDist = np.sqrt(((arySpaceXcrt - 0) ** 2 + (arySpaceYcrt - 0) ** 2),
                  dtype=np.float32)

# Matrices representing the relevant regions of the stimulus

# Mask for central square:
aryLgcCntr = np.logical_and(
                            np.logical_and(
                                           np.greater(arySpaceXcrt,
                                                      tplLimCntrX[0]),
                                           np.less(arySpaceXcrt,
                                                   tplLimCntrX[1])
                                           ),
                            np.logical_and(
                                           np.greater(arySpaceYcrt,
                                                      tplLimCntrY[0]),
                                           np.less(arySpaceYcrt,
                                                   tplLimCntrY[1])
                                           )
                            ).astype(np.float64)

# Avoid fixation dot:
aryLgcCntr[aryDist < varFix] = 0.0

# Mask for full screen:
aryLgcFull = np.ones(arySpaceXcrt.shape, dtype=np.float64)

# Avoid fixation dot:
aryLgcFull[aryDist < varFix] = 0.0

# Mask for edge - restrict outer regions:
aryLgcEdg01 = np.logical_and(
                             np.greater(arySpaceXcrt,
                                        lstLimEdgX[0][0]),
                             np.less(arySpaceXcrt,
                                     lstLimEdgX[1][1])
                             )
aryLgcEdg02 = np.logical_and(
                             np.greater(arySpaceYcrt,
                                        lstLimEdgY[0][0]),
                             np.less(arySpaceYcrt,
                                     lstLimEdgY[1][1])
                             )
aryLgcEdg03 = np.logical_and(aryLgcEdg01, aryLgcEdg02).astype(np.float64)

# Mask for edge - restrict inner regions:
aryLgcEdg04 = np.logical_and(
                             np.greater(arySpaceXcrt,
                                        lstLimEdgX[0][1]),
                             np.less(arySpaceXcrt,
                                     lstLimEdgX[1][0])
                             )
aryLgcEdg05 = np.logical_and(
                             np.greater(arySpaceYcrt,
                                        lstLimEdgY[0][1]),
                             np.less(arySpaceYcrt,
                                     lstLimEdgY[1][0])
                             )
aryLgcEdg06 = np.logical_and(aryLgcEdg04, aryLgcEdg05).astype(np.float64)

# Final edge ROI:
aryLgcEdg = np.subtract(aryLgcEdg03, aryLgcEdg06)

# Mask for periphery (left and right edges of screen):
aryLgcBck = np.logical_or(
                          np.logical_and(
                                         np.greater(arySpaceXcrt,
                                                    lstLimBckX[0][0]),
                                         np.less(arySpaceXcrt,
                                                 lstLimBckX[0][1])
                                         ),
                          np.logical_and(
                                         np.greater(arySpaceXcrt,
                                                    lstLimBckX[1][0]),
                                         np.less(arySpaceXcrt,
                                                 lstLimBckX[1][1])
                                         ),
                          ).astype(np.float64)

# Vectors with x- and y-coordinates represented in the super-sampled model of
# the visual space:
vecXcords = np.linspace(varXmin, varXmax, (varXstep * varSupSmp))
vecYcords = np.linspace(varYmin, varYmax, (varYstep * varSupSmp))

# Dimensions of nii data:
vecNiiShp = aryNiiX.shape
# *****************************************************************************


# *****************************************************************************
# *** Loop through ROIs (central square, edge, periphery)

for idxRoi in range(4):  #noqa

    if idxRoi == 0:
        # Central square
        aryLgcStim = aryLgcCntr
    elif idxRoi == 1:
        # Edge
        aryLgcStim = aryLgcEdg
    elif idxRoi == 2:
        # Periphery (left and right ends of screen)
        aryLgcStim = aryLgcBck
    elif idxRoi == 3:
        # Full screen
        aryLgcStim = aryLgcFull

    # *************************************************************************
    # *** Calculation of stimulus-pRF overlap

    print('---Calculating stimulus-pRF overlap')

    # Empty lists for chunks of nii data:
    lstNiiX = [None] * varPar
    lstNiiY = [None] * varPar
    lstNiiSd = [None] * varPar
    lstNiiR2 = [None] * varPar

    # Empty list for processes:
    lstPrcs = [None] * varPar

    # Empty list for results (stimulus-pRF overlap):
    lstRes = [None] * varPar

    # Counter for parallel processes:
    varCntPar = 0

    # Counter for output of parallel processes:
    varCntOut = 0

    # Create a queue to put the results in:
    queOut = mp.Queue()

    # Total number of voxels:
    varNumVoxTlt = (vecNiiShp[0] * vecNiiShp[1] * vecNiiShp[2])

    # Reshape nii data:
    aryNiiX = np.reshape(aryNiiX, varNumVoxTlt)
    aryNiiY = np.reshape(aryNiiY, varNumVoxTlt)
    aryNiiSd = np.reshape(aryNiiSd, varNumVoxTlt)
    aryNiiR2 = np.reshape(aryNiiR2, varNumVoxTlt)

    # Logical test for voxel inclusion: is the R2 value larger than the
    # specified threshold:
    aryLgcInc = np.greater(aryNiiR2, varThrR)

    # Array nii data for which inclusion condition is fulfilled:
    aryNiiXinc = aryNiiX[aryLgcInc]
    aryNiiYinc = aryNiiY[aryLgcInc]
    aryNiiSdinc = aryNiiSd[aryLgcInc]
    aryNiiR2inc = aryNiiR2[aryLgcInc]

    # Number of voxels for which stimulus-pRF overlap calculation will be
    # performed:
    varNumVoxInc = aryNiiXinc.shape[0]

    print('------Number of voxels on which stimulus-pRF overlap calculation ' +
          'will be performed: ' + str(varNumVoxInc))

    # Vector with the indicies at which the nii data will be separated in order
    # to be chunked up for the parallel processes:
    vecIdxChnks = np.linspace(0,
                              varNumVoxInc,
                              num=varPar,
                              endpoint=False)
    vecIdxChnks = np.hstack((vecIdxChnks, varNumVoxInc))

    # Put nii data into chunks:
    for idxChnk in range(0, varPar):
        # Index of first voxel to be included in current chunk:
        varTmpChnkSrt = int(vecIdxChnks[idxChnk])
        # Index of last voxel to be included in current chunk:
        varTmpChnkEnd = int(vecIdxChnks[(idxChnk+1)])
        # Put array into list:
        lstNiiX[idxChnk] = aryNiiXinc[varTmpChnkSrt:varTmpChnkEnd]
        lstNiiY[idxChnk] = aryNiiYinc[varTmpChnkSrt:varTmpChnkEnd]
        lstNiiSd[idxChnk] = aryNiiSdinc[varTmpChnkSrt:varTmpChnkEnd]
        lstNiiR2[idxChnk] = aryNiiR2inc[varTmpChnkSrt:varTmpChnkEnd]

    print('------Creating parallel processes')

    # Create processes:
    for idxPrc in range(0, varPar):
        lstPrcs[idxPrc] = mp.Process(target=fncPrfOvrlp,
                                     args=(idxPrc,
                                           lstNiiX[idxPrc],
                                           lstNiiY[idxPrc],
                                           lstNiiSd[idxPrc],
                                           lstNiiR2[idxPrc],
                                           aryLgcStim,
                                           varXmin,
                                           varXmax,
                                           varXstep,
                                           varYmin,
                                           varYmax,
                                           varYstep,
                                           varSupSmp,
                                           vecXcords,
                                           vecYcords,
                                           varSdMin,
                                           varPar,
                                           queOut)
                                     )
        # Daemon (kills processes when exiting):
        lstPrcs[idxPrc].Daemon = True

    # Start processes:
    for idxPrc in range(0, varPar):
        lstPrcs[idxPrc].start()

    # Collect results from queue:
    for idxPrc in range(0, varPar):
        lstRes[idxPrc] = queOut.get(True)

    # Join processes:
    for idxPrc in range(0, varPar):
        lstPrcs[idxPrc].join()
    # *************************************************************************

    # *************************************************************************
    # *** Postprocessing

    print('---Post-processing data from parallel processes')

    # Create list for vectors with results, in order to put the results into
    # the correct (original) order:
    lstResRatio = [None] * varPar
    lstResCentre = [None] * varPar

    # Put output into correct order:
    for idxRes in range(0, varPar):

        # Index of results (first item in output list):
        varTmpIdx = lstRes[idxRes][0]

        # Put fitting results into list, in correct order:
        lstResRatio[varTmpIdx] = lstRes[idxRes][1]
        lstResCentre[varTmpIdx] = lstRes[idxRes][2]

    # Concatenate output vectors (into the same order as the voxels that were
    # included in the parallel processes):
    aryRatioInc = np.zeros(0)
    aryCentreInc = np.zeros(0)
    for idxRes in range(0, varPar):
        aryRatioInc = np.append(aryRatioInc, lstResRatio[idxRes])
        aryCentreInc = np.append(aryCentreInc, lstResCentre[idxRes])

    # Delete unneeded large objects:
    del(lstRes)
    del(lstResRatio)
    del(lstResCentre)

    # Arrays for stimulus-pRF overlap results (which will be used to get data
    # into the original shape):
    aryRatio = np.zeros((varNumVoxTlt, 1))
    aryCentre = np.zeros((varNumVoxTlt, 1))

    # Put results form pRF finding into array (they originally needed to be
    # saved in a list due to parallelisation).
    aryRatio[aryLgcInc, 0] = aryRatioInc
    aryCentre[aryLgcInc, 0] = aryCentreInc

    # Reshape results:
    aryRatio = np.reshape(aryRatio,
                          [vecNiiShp[0],
                           vecNiiShp[1],
                           vecNiiShp[2],
                           1])
    aryCentre = np.reshape(aryCentre,
                           [vecNiiShp[0],
                            vecNiiShp[1],
                            vecNiiShp[2],
                            1])
    # *************************************************************************

    # *************************************************************************
    # *** Creation of binary masks for different overlap levels

    print('---Creating binary masks for different overlap levels')

    # Create thresholded maps for pRF models that have their centre on the
    # stimulus. We first create a cell array that will contain the matrices
    # with the masks for each threshold value (several mask with different
    # thresholds can be produced at once).
    varNumMsk = len(lstOvrlp)
    lstMsk = [None] * varNumMsk
    # Loop through overlap threshold values:
    for idxMsk in range(0, varNumMsk):
        lstMsk[idxMsk] = (aryRatio >= lstOvrlp[idxMsk]) * aryCentre
    # *************************************************************************

    # *************************************************************************
    # *** Export results

    print('---Exporting results')

    # Create nii objects for ratio and centre images:
    niiOtRatio = nib.Nifti1Image(aryRatio,
                                 aryAffX,
                                 header=hdrNiiX
                                 )
    niiOtCentre = nib.Nifti1Image(aryCentre,
                                  aryAffX,
                                  header=hdrNiiX
                                  )

    if idxRoi == 0:
        # Central square
        strHmf = 'square_centre'
    elif idxRoi == 1:
        # Edge
        strHmf = 'square_edge'
    elif idxRoi == 2:
        # Periphery (left and right ends of screen)
        strHmf = 'background'
    elif idxRoi == 3:
        # Full screen (avoiding fixation dot)
        strHmf = 'fullscreen'

    # Save nii to disk:
    nib.save(niiOtRatio, (strNiiOt + 'ovrlp_ratio_' + strHmf + '.nii.gz'))
    nib.save(niiOtCentre, (strNiiOt + 'ovrlp_ctnr_' + strHmf + '.nii.gz'))

    # Export overlap ratio images:
    for idxMsk in range(0, varNumMsk):

        # Create nii object:
        niiOtTmp = nib.Nifti1Image(lstMsk[idxMsk],
                                   aryAffX,
                                   header=hdrNiiX
                                   )

        # Save nii to disk:
        strTmp = (strNiiOt
                  + 'ovrlp_mask_'
                  + str(lstOvrlp[idxMsk])
                  + 'prct_'
                  + strHmf
                  + '.nii.gz')
        nib.save(niiOtTmp, strTmp)
    # *************************************************************************


# *****************************************************************************
# *** Report time

varTme02 = time.time()
varTme03 = varTme02 - varTme01
print('-Elapsed time: ' + str(varTme03) + ' s')
print('-Done.')
# *****************************************************************************
