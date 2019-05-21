#!/bin/bash

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


################################################################################
# Metascript for the Texture analysis pipeline.                                #
################################################################################


#-------------------------------------------------------------------------------
# ### Define paths

# Subject ID:
pacman_sub_id="20190502"

# Analysis parent directory (containing scripts):
pacman_anly_path="/home/john/PhD/GitLab/texture/analysis/"

# Data parent directory (containing MRI data):
pacman_data_path="/media/sf_D_DRIVE/MRI_Data_PhD/11_texture/"

# Segmentation version (segmentation files need to be at `${pacman_anly_path}
# ${pacman_sub_id}/08_depthsampling/${pacman_sub_id}_mp2rage_seg_
# ${pacman_seg_version}`):
pacman_seg_version="v04"
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Export paths

# Export paths and variables so that all other scripts can use them.
export pacman_sub_id
export pacman_anly_path
export pacman_data_path
export pacman_seg_version
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# ### Activate docker image

# Enable x11 clients (at the host)
xhost +local:all

# Run docker from image with shared folders. Environmental variables are passed
# in with the '-e' flag.
docker run -it --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ${pacman_data_path}:${pacman_data_path} \
    -v ${pacman_anly_path}:${pacman_anly_path} \
    -e pacman_sub_id \
    -e pacman_anly_path \
    -e pacman_data_path \
    -e pacman_seg_version \
    dockerimage_cbs ${pacman_anly_path}${pacman_sub_id}/08_depthsampling/depthsampling_metascript.sh &> /home/john/Dropbox/Sonstiges/docker_log_cbs_${pacman_sub_id}.txt
#-------------------------------------------------------------------------------
