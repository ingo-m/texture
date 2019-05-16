#!/bin/bash


################################################################################
# The purpose of this script is to perform distortion correction on opposite   #
# phase-encoding data. The input data need to be motion-corrected beforehands. #
# You may use a modified topup configuration file for better results.          #
################################################################################


echo "-Distortion correction"


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Parent directory:
strPathParent="${pacman_data_path}${pacman_sub_id}/nii/"

# Functional runs (input & output):
aryRun=(func_01 \
        func_02 \
        func_03 \
        func_04 \
        func_05 \
        func_06 \
        func_07 \
        func_08)

# Path for 'datain' text file with acquisition parameters for applytopup (see
# TOPUP documentation for details):
strDatain02="${pacman_anly_path}${pacman_sub_id}/01_preprocessing/n_06c_datain_applytopup.txt"

# Parallelisation factor:
varPar=5

# Path of images to be undistorted (input):
strPathFunc="${strPathParent}func_reg/"

# Path for bias field (input):
strPathRes01="${strPathParent}func_distcorField/"

# Path for undistorted images (output):
strPathRes02="${strPathParent}func_reg_distcorUnwrp/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Preparations

echo "---Preparations"

# Number of runs:
varNumRun=${#aryRun[@]}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Apply distortion correction:

echo "---Apply distortion correction"
date

# Parallelisation over runs:
for idxRun in $(seq 0 $((${varNumRun} - 1)))
do

	#echo "------Run: ${aryRun[idxRun]}" &

	applytopup \
	--imain=${strPathFunc}${aryRun[idxRun]} \
	--datain=${strDatain02} \
	--inindex=1 \
	--topup=${strPathRes01}func_00 \
	--out=${strPathRes02}${aryRun[idxRun]} \
	--method=jac &

	# Check whether it's time to issue a wait command (if the modulus of the
	# index and the parallelisation-value is zero):
	if [[ $((${idxRun} + 1))%${varPar} -eq 0 ]]
	then
		# Only issue a wait command if the index is greater than zero (i.e.,
		# not for the first segment):
		if [[ ${idxRun} -gt 0 ]]
		then
			wait
			echo "------Progress: $((${idxRun} + 1)) runs out of" \
				"${varNumRun}"
		fi
	fi
done
wait
date
#------------------------------------------------------------------------------
