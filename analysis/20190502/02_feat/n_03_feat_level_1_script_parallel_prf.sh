#!/bin/bash

#-------------------------------------------------------------------------------
# ### Prepare fsf files

# Get path of fsf files from environmental variables:
str_path="${pacman_anly_path}${pacman_sub_id}/02_feat/level_1_fsf_prf/"

# Replace path placeholders in fsf files, creating temporary fsf files (it does
# not seem to be possible to pipe the result from sed directly into feat).
NEW_DATA_PATH="${pacman_data_path}${pacman_sub_id}/"
NEW_ANALYSIS_PATH="${pacman_anly_path}"

# Functional runs:
arySessionIDs=(prf_01 \
               prf_02)

for index01 in ${arySessionIDs[@]}
do
	# Copy the existing fsf file:
	cp ${str_path}feat_level_1_${index01}.fsf ${str_path}feat_level_1_${index01}_sed.fsf

	# Replace placeholders with path of current subject:
	sed -i "s|PLACEHOLDER_FOR_DATA_PATH|${NEW_DATA_PATH}|g" ${str_path}feat_level_1_${index01}_sed.fsf
	sed -i "s|PLACEHOLDER_FOR_ANALYSIS_PATH|${NEW_ANALYSIS_PATH}|g" ${str_path}feat_level_1_${index01}_sed.fsf
done
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# ### Run FEAT analysis

echo "-----------First level feat:-----------"

echo "---pRF runs 01, 02, 03"

date
feat "${str_path}feat_level_1_prf_01_sed.fsf" &
feat "${str_path}feat_level_1_prf_02_sed.fsf" &
wait

date

echo "done"
#-------------------------------------------------------------------------------
