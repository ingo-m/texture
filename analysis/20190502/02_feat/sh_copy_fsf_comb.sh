#!/bin/bash


################################################################################
# The purpose of this script is to create multiple copies of an fsf file (i.e. #
# text file containing parameters for a feat analysis) for several runs. The   #
# resulting feat files are identical to the original one, with the exception   #
# of the string refering to the run ID (i.e. "func_01", "func_02", etc.).      #
# Required inputs:                                                             #
#	- parent path                                                                #
#	- array containing the name of the original fsf file (first entry) and       #
#	  of all the fsf files to be created (arySessionIDs01)                       #
#	- array with the strings to be used as run IDs in the files to be            #
#	  created (and the respective string that will be replaced as the            #
#	  first entry)                                                               #
################################################################################


#-------------------------------------------------------------------------------
# Define session IDs & paths:

# Parent path:
strPathParent="/home/john/PhD/GitLab/kanizsa/analysis/20190213/02_feat/level_1_fsf_comb/"

# Array with the file names of the fsf file (first entry = existing fsf file)
arySessionIDs01=(feat_level_1_func_01 \
                 feat_level_1_func_02 \
                 feat_level_1_func_03 \
                 feat_level_1_func_04 \
                 feat_level_1_func_05 \
                 feat_level_1_func_06)

# Array with the run IDs to be placed in the fsf files (first entry = run ID in
# existing fsf file)
arySessionIDs02=(func_01 \
                 func_02 \
                 func_03 \
                 func_04 \
                 func_05 \
                 func_06)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Create copies of existing fsf file and replace strings:

# Count number of runs:
varNumRuns=${#arySessionIDs01[@]}
varNumRuns=$((varNumRuns-1))


for index_1 in $(seq 0 $varNumRuns)
do
	if  [[ ${index_1} < 1 ]]
	then
		# Create copies of existing fsf file:
		echo "-----Create copies of existing fsf file:"
		for index_2 in $(seq 1 $varNumRuns)
		do
			strTmp01="${strPathParent}${arySessionIDs01[0]}.fsf"		# existing fsf file
			strTmp02="${strPathParent}${arySessionIDs01[${index_2}]}.fsf"	# fsf file to be created
			echo "cp ${strTmp01} ${strTmp02}"
			cp ${strTmp01} ${strTmp02}
		done
	else
		# Replace strings:
		echo "-----Replace strings:"
		strTmp01="${strPathParent}${arySessionIDs01[${index_1}]}.fsf"	# fsf file to be modified
		strTmp02="${arySessionIDs02[0]}"					# string to be replaced
		strTmp03="${arySessionIDs02[index_1]}"				# string to replace the previous string
		echo "sed -i "s/${strTmp02}/${strTmp03}/g ${strTmp01}""
		sed -i "s/${strTmp02}/${strTmp03}/g" ${strTmp01}
	fi
done
#-------------------------------------------------------------------------------
