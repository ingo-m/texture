#!/bin/bash


###############################################################################
# The purpose of this script is to preprocess data of the PacMan experiment.  #
# The following steps are performed in this script:                           #
#   - Copy files into SPM directory tree                                      #
# Motion correction and registrations are performed with SPM afterwards.      #
###############################################################################


#-------------------------------------------------------------------------------
# Define session IDs & paths:

# Parent directory:
strPathParent="${pacman_data_path}${pacman_sub_id}/nii/"

# Functional runs (input):
arySessionIDs=(func_00)

# Input directory:
strPathInput="${strPathParent}func_se/"

# SPM directory:
strPathSpmParent="${strPathParent}spm_reg/"
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Change filetype and save resulting nii file to SPM directory:

# SPM requires *.nii files as input, not *.nii.gz.

echo "-----Change filetype and save resulting nii file to SPM directory:-----"
date

for index01 in ${arySessionIDs[@]}
do
	strTmp01="${strPathInput}${index01}"
	strTmp02="${strPathSpmParent}${index01}/${index01}"

	echo "---fslchfiletype on: ${strTmp01}"
	echo "-------------output: ${strTmp02}"
	echo "---fslchfiletype NIFTI ${strTmp01} ${strTmp02}"
	fslchfiletype NIFTI ${strTmp01} ${strTmp02}

	# Remove input:
	# echo "---rm ${strTmp01}.nii.gz"
	# rm "${strTmp01}.nii.gz"
done

date
echo "done"
#-------------------------------------------------------------------------------
