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


###############################################################################
# Depth sampling meta script. Perform depth sampling with CBS tools and post- #
# process results (file renaming and conversion of event-related time course  #
# vtk meshes to npy format).                                                  #
###############################################################################


#------------------------------------------------------------------------------
# ### Preparations

# Location of CBS layouts & python scripts to run:
strPthCbs="${pacman_anly_path}${pacman_sub_id}/08_depthsampling/"

# Names of CBS layouts to run (xml files):
aryCbs=(cbs_lh_glm_prf.LayoutXML \
        cbs_rh_glm_prf.LayoutXML \
        cbs_lh_ert.LayoutXML \
        cbs_rh_ert.LayoutXML)

# Names of python scripts to run:
aryPy=(renameJistOutput.py \
       renameJistOutput_ert.py \
       postprocess_retinotopy_vtk_lh.py \
       postprocess_retinotopy_vtk_rh.py \
       vtk_to_npy_conversion.py)

# Working directory:
strPthWd="${pacman_data_path}${pacman_sub_id}/cbs/cbs_wd"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Prepare xml layout files

echo "-Depth sampling"

date

echo "--Prepare xml layouts"

# The placeholder for input pahts, subject ID, and segmentation version need to
# be replaced.

for index01 in ${aryCbs[@]}
do
    # Copy the existing xml file:
    cp ${strPthCbs}${index01} ${strPthCbs}sed_${index01}

    # Replace placeholders with path of current subject:
    sed -i "s|pacman_sub_id|${pacman_sub_id}|g" ${strPthCbs}sed_${index01}
    sed -i "s|pacman_anly_path|${pacman_anly_path}|g" ${strPthCbs}sed_${index01}
    sed -i "s|pacman_data_path|${pacman_data_path}|g" ${strPthCbs}sed_${index01}
    sed -i "s|pacman_seg_version|${pacman_seg_version}|g" ${strPthCbs}sed_${index01}
done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Loop through CBS layouts

echo "--CBS depth sampling"

# Create an alias for mipav:
# alias mipavjava="/home/john/mipav/jre/bin/java -classpath \
# /home/john/mipav/plugins/:/home/john/mipav/:`find /home/john/mipav/ -name \
# \*.jar | sed 's#/home/john/mipav/#:/home/john/mipav/#' | tr -d '\n' | sed \
# 's/^://'`"
long_mipavjava_alias="/home/john/mipav/jre/bin/java -classpath /home/john/mipav/plugins/:/home/john/mipav/:`find /home/john/mipav/ -name \*.jar | sed 's#/home/john/mipav/#:/home/john/mipav/#' | tr -d '\n' | sed 's/^://'`"

for idx01 in ${aryCbs[@]}
do
    # Create working directory:
    mkdir ${strPthWd}

    # Absolute path of current CBS layout:
    strPthCbsTmp=${strPthCbs}sed_${idx01}

    echo "---Running CBS layout: ${strPthCbsTmp}"

    # Run CBS layout through mipav:
    # mipavjava edu.jhu.ece.iacl.jist.cli.runLayout \
    ${long_mipavjava_alias} edu.jhu.ece.iacl.jist.cli.runLayout \
    ${strPthCbsTmp} \
    -xRunOutOfProcess \
    -xJreLoc /home/john/mipav/jre/bin/java \
    -xDir ${strPthWd} \
    -xClean

    # Remove working directory (results are copied to destination directory
    # within the CBS layout):
    rm -r ${strPthWd}
done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# ### Loop through postprocessing python scripts

echo "--Postprocessing"

for idx02 in ${aryPy[@]}
do
    # Absolute path of current python script:
    strPyTmp=${strPthCbs}${idx02}

    echo "---Running: ${strPyTmp}"

    # Run the python script:
    python ${strPyTmp}
done

date

echo "-Done."
#------------------------------------------------------------------------------
