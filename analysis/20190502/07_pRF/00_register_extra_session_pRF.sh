#!/bin/bash


# For subject 20190213 there are additional pRF runs from a previous session:
#     20181105: 3 pRF runs
# Here, the extra-session pRF runs are registered to session 20190213 (this
# session). The transformation matrix was calculated using ITK snap, based on
# the mean EPI images from from the respective sessions, and converted into an
# FSL transformation matrix using the c3d_affine_tool:
#     c3d_affine_tool \
#     ~/20181105_to_20190213_itk.mat \
#     -info \
#     -ref ~/20190213_combined_mean.nii.gz \
#     -src ~/20181105_combined_mean.nii.gz \
#     -ras2fsl \
#     -o ~/20181105_to_20190213_fsl.mat
# Note: The pervious experiment (i.e. session 20181105) needs to be processed
# first, so that the data can be registered here.


# -----------------------------------------------------------------------------
# ### Preparations

# Path of transformation matrices:
strPthMat01="${pacman_anly_path}${pacman_sub_id}/07_pRF/20181105_to_20190213_fsl.mat"
# strPthMat02="${pacman_anly_path}${pacman_sub_id}/07_pRF/xxxxxxxx_to_xxxxxxxx_fsl.mat"

# Target directory for extra-session pRF data:
strPthOut="${pacman_data_path}20190213/nii/retinotopy/extrasession"

# Path of mean EPI image from target session (i.e. 20190213), used as
# reference.
strPthRef="${pacman_data_path}20190213/nii/func_reg_tsnr/combined_mean.nii.gz"

# Input parent directory (containing motion-corrected, distortion-corrected,
# feat-high-pass-filtered extra-session pRF data).
strPthIn="${pacman_data_path}BIDS/${pacman_sub_id_bids}/extrasession_prf/"

# Create directory for extra-session pRF data:
# mkdir ${strPthOut}
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# ### Register extra-session pRF data - 20181105

flirt \
-interp trilinear \
-in ${strPthIn}20181105_prf_01.nii.gz \
-ref ${strPthRef} \
-applyxfm -init ${strPthMat01} \
-out ${strPthOut}/20181105_prf_01

flirt \
-interp trilinear \
-in ${strPthIn}20181105_prf_02.nii.gz \
-ref ${strPthRef} \
-applyxfm -init ${strPthMat01} \
-out ${strPthOut}/20181105_prf_02

flirt \
-interp trilinear \
-in ${strPthIn}20181105_prf_03.nii.gz \
-ref ${strPthRef} \
-applyxfm -init ${strPthMat01} \
-out ${strPthOut}/20181105_prf_03
# -----------------------------------------------------------------------------
