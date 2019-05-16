#!/bin/bash


################################################################################
# Copy mean & tSNR images.                                                     #
################################################################################


#-------------------------------------------------------------------------------
# Define session IDs & paths:

strPathParent="${pacman_data_path}${pacman_sub_id}/nii/func_reg_tsnr/"

# Functional runs (input & output):
lstIn=(combined_mean \
       combined_mean_tSNR)

strPathOutput="${pacman_data_path}${pacman_sub_id}/nii/stat_maps_comb/"
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Copy images:

echo "---Copy images---"
date

for index01 in ${lstIn[@]}
do

	strTmpIn="${strPathParent}${index01}.nii.gz"
	strTmpOut="${strPathOutput}${index01}.nii.gz"
	echo "------cp ${strTmpIn} ${strTmpOut}"
	cp ${strTmpIn} ${strTmpOut}

done

date
echo "done"
#-------------------------------------------------------------------------------
