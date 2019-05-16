#!/bin/bash


###############################################################################
# The purpose of this script is to calculate field maps for distortion        #
# correction from opposite-phase-polarity data. The input data need to be     #
# motion-corrected beforehands. A modified topup configuration may be used.   #
###############################################################################


echo "-Distortion correction"


#------------------------------------------------------------------------------
# Define session IDs & paths:

# Parent directory:
strPathParent="${pacman_data_path}${pacman_sub_id}/nii/"

# Functional runs (input & output):
aryRun=(func_00)

# Name of configuration file:
strPathCnf="${pacman_anly_path}${pacman_sub_id}/01_preprocessing/n_05b_highres.cnf"


# Path for 'datain' text file with acquisition parameters for topup (see TOPUP
# documentation for details):
strDatain01="${pacman_anly_path}${pacman_sub_id}/01_preprocessing/n_05c_datain_topup.txt"

# Parallelisation factor:
varPar=1

# Path of images to be undistorted (input):
strPathFunc="${strPathParent}func_se_reg/"

# Path of opposite-phase encode run (input):
strPathOpp="${strPathParent}func_se_op_inv_reg/"

# Path for merged opposite-phase encode pair (intermediate output):
strPathMerged="${strPathParent}func_se_merged/"

# Path for bias field (intermediate output):
strPathRes01="${strPathParent}func_distcorField/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Preparations

echo "---Preparations"

# Number of runs:
varNumRun=${#aryRun[@]}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Merge opposite-phase-polarity image pairs:

echo "---Merge opposite-phase-polarity image pairs"
date

for idxRun in $(seq 0 $((${varNumRun} - 1)))
do

	#echo "------Run: ${aryRun[idxRun]}" &

	fslmerge \
	-t \
	${strPathMerged}${aryRun[idxRun]} \
	${strPathFunc}${aryRun[idxRun]} \
	${strPathOpp}${aryRun[idxRun]} &

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


#------------------------------------------------------------------------------
# Calculate field maps:

echo "------Calculate field maps"
date

# Parallelisation over runs:
for idxRun in $(seq 0 $((${varNumRun} - 1)))
do

	#echo "------Run: ${aryRun[idxRun]}" &

	topup \
	--imain=${strPathMerged}${aryRun[idxRun]} \
	--datain=${strDatain01} \
	--config=${strPathCnf} \
	--out=${strPathRes01}${aryRun[idxRun]} &

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
