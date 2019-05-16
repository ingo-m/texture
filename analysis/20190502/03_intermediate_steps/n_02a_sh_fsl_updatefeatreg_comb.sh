#!/bin/bash


################################################################################
# The purpose of this script is to prepare folders with the results of a feat  #
# first level analysis for second level analysis when no registration to       #
# standard was performed as part of feat (because the functional time series   #
# have already been motion corrected and registered to 'standard space' before #
# running feat). The steps to be performed are:                                #
#    - Copying of dummy 'reg' folders (identity matrices) to feat level 1      #
#      directories, including copying of repsective nii files                  #
#    - updatefeatreg                                                           #
################################################################################
# Note: Both the path of the feat directories (strPathParent) and the path     #
# of the standard image (strPathStd) need to be adjusted.                      #
################################################################################


#-------------------------------------------------------------------------------
# Define session IDs & paths:

# The parent directory:
strPathParent="${pacman_data_path}${pacman_sub_id}/nii/"

# The directory with the first level feat results:
strPathFeat="${strPathParent}feat_level_1_comb/"

# The FEAT sub-directories:
aryFeatIDs=(func_01.feat \
            func_02.feat \
            func_03.feat \
            func_04.feat \
            func_05.feat \
            func_06.feat)

# The path of the 'standard' image:
strPathStd="${strPathParent}func_reg_tsnr/combined_mean.nii.gz"

# The path of the identity matrix:
strPathMatIdent="${pacman_anly_path}FSL_MRI_Metadata/mat_reg_identity"
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Define session IDs & paths:

for index01 in ${aryFeatIDs[@]}
do
	echo "processing ${index01}"

	# Define temporary paths:
	strTmp01="${strPathFeat}${index01}/"
	strTmp02="${strTmp01}example_func.nii.gz"
	strTmp03="${strTmp01}reg/example_func.nii.gz"
	strTmp04="${strTmp01}reg/example_func2standard.mat"
	strTmp05="${strTmp01}reg/example_func2standard.nii.gz"
	strTmp06="${strTmp01}reg/standard.nii.gz"
	strTmp07="${strTmp01}reg/standard2example_func.mat"

	# Create reg directory:
	echo "Creating reg directory"
	mkdir "${strTmp01}reg"

	# Copy files:
	echo "Copying files"
	cp ${strTmp02} ${strTmp03}
	cp ${strPathMatIdent} ${strTmp04}
	cp ${strTmp02} ${strTmp05}
	cp ${strPathStd} ${strTmp06}
	cp ${strPathMatIdent} ${strTmp07}

	# updatefeatreg
	echo "updatefeatreg ${strTmp01}"
	updatefeatreg ${strTmp01}
done
#-------------------------------------------------------------------------------
