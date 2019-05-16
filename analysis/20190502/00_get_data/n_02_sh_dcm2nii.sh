#!/bin/bash

# Conversion of dicom to nii
dcm2niix \
-6 \
-b y \
-ba y \
-f PROTOCOL_%p_SERIES_%3s \
-g n \
-i n \
-m n \
-o ${pacman_data_path}${pacman_sub_id}/nii/raw_data/ \
-p n \
-s n \
-t n \
-v 0 \
-x n \
-z y \
${pacman_data_path}${pacman_sub_id}/dicoms/
