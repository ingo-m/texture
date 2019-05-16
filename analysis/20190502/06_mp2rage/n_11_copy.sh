#!/bin/bash

################################################################################
# Copy registered images for segmentation.                                     #
################################################################################

echo "-Copy registered images for segmentation"

cp \
${pacman_data_path}${pacman_sub_id}/nii/mp2rage/03_reg/04_reg/04_inv_bbr/*.nii.gz \
${pacman_data_path}${pacman_sub_id}/nii/mp2rage/04_seg/

cp \
${pacman_data_path}${pacman_sub_id}/nii/mp2rage/03_reg/01_in/combined_mean.nii.gz \
${pacman_data_path}${pacman_sub_id}/nii/mp2rage/04_seg/

cp \
${pacman_data_path}${pacman_sub_id}/nii/mp2rage/03_reg/01_in/combined_mean_tSNR.nii.gz \
${pacman_data_path}${pacman_sub_id}/nii/mp2rage/04_seg/
