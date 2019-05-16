#!/bin/bash


################################################################################
# Metascript for the ParMan analysis pipeline.                                 #
################################################################################


#-------------------------------------------------------------------------------
# ### Define paths

# Subject ID:
pacman_sub_id="20190502"

# BIDS subject ID:
pacman_sub_id_bids="sub-01"

# Analysis parent directory (containing scripts):
pacman_anly_path="/home/john/PhD/GitLab/texture/analysis/"

# Data parent directory (containing MRI data). If working with the BIDS data,
# this data should be placed here (i.e. this folder should contain a folder
# called 'BIDS', which in turn contains the subject directories, such as
# '~/BIDS/sub-01/...').
pacman_data_path="/media/sf_D_DRIVE/MRI_Data_PhD/11_texture/"

# Whether to load data from BIDS structure. If 'true', data is loaded from BIDS
# structure. If 'false', DICOM data is converted into BIDS-compatible nii first.
pacman_from_bids=false

# Wait for manual user input? When running the analysis for the first time, some
# steps need to be performed manually (e.g. creation of brain masks for moco
# reference weighting, and for registration). The script will pause and wait
# until the user provides the manual input. However, if the manual input is
# already available (when re-running the analysis), these breaks can be skipped.
# Set to 'true' if script should wait.
pacman_wait=true

# Number of parallel processes to use (for pRF finding):
pacman_cpu="11"
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Export paths

# Export paths and variables so that all other scripts can use them.
export pacman_sub_id
export pacman_sub_id_bids
export pacman_anly_path
export pacman_data_path
export pacman_from_bids
export pacman_wait
export pacman_cpu
export USER=john
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# ### Activate docker image

# Run dockerfrom image with shared folders (analysis folder is read-only).
# Environmental variables are passed in with the '-e' flag.
docker run -it --rm \
    -v ${pacman_data_path}:${pacman_data_path} \
    -v ${pacman_anly_path}:${pacman_anly_path} \
    -e pacman_sub_id \
    -e pacman_sub_id_bids \
    -e pacman_anly_path \
    -e pacman_data_path \
    -e pacman_from_bids \
    -e pacman_wait \
    -e pacman_cpu \
    -e USER \
    dockerimage_surface_jessie ${pacman_anly_path}${pacman_sub_id}/metascript_02.sh
#-------------------------------------------------------------------------------
