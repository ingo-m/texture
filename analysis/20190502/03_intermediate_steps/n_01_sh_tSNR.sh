#!/bin/bash


################################################################################
# Calculate tSNR of functional time series.                                    #
################################################################################


#-------------------------------------------------------------------------------
# Define session IDs & paths:

# Functional runs (input):
arySessionIDs=(func_01 \
               func_02 \
               func_03 \
               func_04 \
               func_05 \
               func_06 \
               prf_01 \
               prf_02)

# Parent path:
strPathParent="${pacman_data_path}${pacman_sub_id}/nii/"

# Path of feat directorie, main experiment:
strPathInputMain="${strPathParent}feat_level_1_comb/"

# Path of feat directorie, pRF mapping:
strPathInputPrf="${strPathParent}feat_level_1_prf/"

# Output directory:
strPathOutput="${strPathParent}func_reg_tsnr/"
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Create 3D tSNR images for all functional time series:

echo "-------------------------------------------------------------------------"
echo "----- Create 3D tSNR images for all functional time series: -----"
for index01 in ${arySessionIDs[@]}
do

  # Input directory - main experiment or pRF run? Test whether "prf" substring
  # is contained in run ID:
  if [[ ${index01} == *"prf"* ]];
  then
	   strTmp01="${strPathInputPrf}${index01}.feat/filtered_func_data"
  else
	   strTmp01="${strPathInputMain}${index01}.feat/filtered_func_data"
  fi

	strTmp02="${strPathOutput}${index01}_mean.nii"
	strTmp03="${strPathOutput}${index01}_sd.nii"
	strTmp04="${strPathOutput}${index01}_tSNR.nii"

	echo "fslmaths ${strTmp01} -Tmean ${strTmp02}"
	fslmaths ${strTmp01} -Tmean ${strTmp02}

	echo "fslmaths ${strTmp01} -Tstd ${strTmp03}"
	fslmaths ${strTmp01} -Tstd ${strTmp03}

	echo "fslmaths ${strTmp02} -div ${strTmp03} ${strTmp04}"
	fslmaths ${strTmp02} -div ${strTmp03} ${strTmp04}

	echo "done"
done
echo "-------------------------------------------------------------------------"
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Create mean 3D tSNR image:

echo "----- Create mean 3D tSNR image: -----"

# The name of the final combined mean tSNR image (i.e. the average of the
# individual tSNR images):
strTmp05="${strPathOutput}combined_mean_tSNR.nii.gz"

# Counter that is used to divide the sum of all individual tSNR images by N at
# the end:
varCount=$((0))

for index01 in ${arySessionIDs[@]}
do
	strTmp04="${strPathOutput}${index01}_tSNR.nii.gz"

	if [[ ${index01} = ${arySessionIDs[0]} ]]
	then
		# The starting point for the combined tSNR image is the first
		# individual tSNR image. The other individual tSNR images are
		# subsequently added.
		echo "cp ${strTmp04} ${strTmp05}"
		cp ${strTmp04} ${strTmp05}
	else
		echo "fslmaths ${strTmp05} -add ${strTmp04} ${strTmp05}"
		fslmaths ${strTmp05} -add ${strTmp04} ${strTmp05}
	fi
	varCount=$((varCount+1))
	echo "count: ${varCount}"
done

# Divide sum of all individual tSNR images by N:
echo "fslmaths ${strTmp05} -div ${varCount} ${strTmp05}"
fslmaths ${strTmp05} -div ${varCount} ${strTmp05}
echo "-------------------------------------------------------------------------"
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Create combined mean image of all time series:

echo "----- Create combined mean image of all time series: -----"

# The name of the final combined mean image (i.e. the average mean image of all
# functional time series):
strTmp06="${strPathOutput}combined_mean.nii.gz"

# Counter that is used to divide the sum of all individual mean images at the
# end:
varCount=$((0))

for index01 in ${arySessionIDs[@]}
do
	strTmp02="${strPathOutput}${index01}_mean.nii.gz"

	if [[ ${index01} = ${arySessionIDs[0]} ]]
	then
		# The combined mean image is initially set to the first
		# individual mean image.  The other individual mean images are
		# subsequently added.
		echo "cp ${strTmp02} ${strTmp06}"
		cp ${strTmp02} ${strTmp06}
	else
		echo "fslmaths ${strTmp06} -add ${strTmp02} ${strTmp06}"
		fslmaths ${strTmp06} -add ${strTmp02} ${strTmp06}
	fi

	varCount=$((varCount+1))
	echo "count: ${varCount}"
done

# Divide sum of all images by N:
echo "fslmaths ${strTmp06} -div ${varCount} ${strTmp06}"
fslmaths ${strTmp06} -div ${varCount} ${strTmp06}

echo "--------------------------------------------------------------"
