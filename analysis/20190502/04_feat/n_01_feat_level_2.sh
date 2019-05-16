#!/bin/bash

#-------------------------------------------------------------------------------
# ### Prepare fsf files

# Get path of fsf files from environmental variables:
str_path="${pacman_anly_path}${pacman_sub_id}/04_feat/level_2_fsf/"

# Replace path placeholders in fsf files, creating temporary fsf files (it does
# not seem to be possible to pipe the result from sed directly into feat).
NEW_DATA_PATH="${pacman_data_path}${pacman_sub_id}/"
NEW_ANALYSIS_PATH="${pacman_anly_path}"

# fsf files:
aryFsfFiles=(feat_level_2_kanizsa_flicker_sst \
             feat_level_2_kanizsa_flicker_trn \
             feat_level_2_kanizsa_static_sst \
             feat_level_2_kanizsa_static_trn \
             feat_level_2_rotated_flicker_sst \
             feat_level_2_rotated_flicker_trn \
             feat_level_2_rotated_static_sst \
             feat_level_2_rotated_static_trn \
             feat_level_2_target)

for index01 in ${aryFsfFiles[@]}
do
	# Copy the existing fsf file:
	cp ${str_path}${index01}.fsf ${str_path}${index01}_sed.fsf

	# Replace placeholders with path of current subject:
	sed -i "s|PLACEHOLDER_FOR_DATA_PATH|${NEW_DATA_PATH}|g" ${str_path}${index01}_sed.fsf
	sed -i "s|PLACEHOLDER_FOR_ANALYSIS_PATH|${NEW_ANALYSIS_PATH}|g" ${str_path}${index01}_sed.fsf
done
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# ### Run FEAT analysis

echo "-----------Second level feat:-----------"

date

for index01 in ${aryFsfFiles[@]}
do
	# Run 2nd level feat analysis:
	feat "${str_path}${index01}_sed.fsf"
done

date

echo "done"
#-------------------------------------------------------------------------------
