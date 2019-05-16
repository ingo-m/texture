#!/bin/bash


###############################################################################
# Create mean undistorted SE EPI image.                                       #
###############################################################################


# -----------------------------------------------------------------------------
# *** Define session IDs & paths:

# Input file:
strPthIn="${pacman_data_path}${pacman_sub_id}/nii/func_reg_distcorUnwrp/func_00.nii.gz"

# Ouput file:
strPthOut="${pacman_data_path}${pacman_sub_id}/nii/func_reg_tsnr/se_epi_mean"
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Calculate mean image

fslmaths ${strPthIn} -Tmean ${strPthOut}
# -----------------------------------------------------------------------------
