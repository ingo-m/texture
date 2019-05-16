#!/bin/bash


################################################################################
# The purpose of this script is to prepare the depth-sampling of event-related #
# averages. The following steps are performed:                                 #
#    - Event-related averages (4D nii files) are upsampled                     #
#    - The upsampled event-related averages are split into 3D files            #
#    - Data from intermediate steps are removed                                #
################################################################################


echo "-Preparing depth-sampling of event-related timecourses."


# -----------------------------------------------------------------------------
# *** Define session IDs & paths

# Subject IDs:
arySubIDs=(${pacman_sub_id})

# Input parent directory ('SUBJECT_ID' will be replaced):
strIn="${pacman_data_path}SUBJECT_ID/nii/func_reg_averages/"

# Input file names (within parent directory):
aryNiiIn=(ERA_bright_square_txtr \
          ERA_full_screen_txtr)

# Output parent directory ('SUBJECT_ID' will be replaced):
strOt="${pacman_data_path}SUBJECT_ID/nii/func_reg_averages/"

# Upsampling factor (e.g. 0.5 for half the previous voxel size, 0.25 for a
# quater of the previous voxel size):
varUpFac=0.5
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Loop over subjects

for strSub in ${arySubIDs[@]}
do

  echo "--Subject: ${strSub}"

  # Prepare temporary strings for current subject:
  strInTmp=${strIn/SUBJECT_ID/${strSub}}
  strOtTmp=${strOt/SUBJECT_ID/${strSub}}

  echo "---Input path: ${strInTmp}"
  echo "---Output path: ${strOtTmp}"

	#-----------------------------------------------------------------------------
	# *** Preparations

	echo "---Preparations"

	# Save original path in order to cd back to this path in the end:
	strPathOrig=( $(pwd) )

	# cd into target directory:
	cd "${strInTmp}"

	# Gzip all nii files in input parent directory (nothing happens if they are
	# already in compressed format):
	gzip *.nii

	# cd back to original directory:
	cd "${strPathOrig}"
	#-----------------------------------------------------------------------------


	#-----------------------------------------------------------------------------
	# *** Upsample event-related averages

	echo "---Upsample event-related averages"

	# Calculate inverse of upsampling factor (for caculation of new matrix size):
	varUpInv=`bc <<< 1/${varUpFac}`

	# Check number of files to be processed:
	varNumIn=${#aryNiiIn[@]}

	# Since indexing starts from zero, we subtract one:
	varNumIn=$((varNumIn - 1))

	for idxIn in $(seq 0 $varNumIn)
	do
		# Define temporary path of current input image:
		strTmpIn="${strInTmp}${aryNiiIn[idxIn]}.nii.gz"

		echo "------Processing ${aryIn[idxIn]}"
		date

		# Get dimensions of current input image:
		strDim01=`fslinfo ${strTmpIn} | grep -w dim1 | sed -e 's/dim1//'`
		strDim02=`fslinfo ${strTmpIn} | grep -w dim2 | sed -e 's/dim2//'`
		strDim03=`fslinfo ${strTmpIn} | grep -w dim3 | sed -e 's/dim3//'`
		strDim04=`fslinfo ${strTmpIn} | grep -w dim4 | sed -e 's/dim4//'`

		# Get voxel size of current input image:
		strPixdim01=`fslinfo ${strTmpIn} | grep -w pixdim1 | sed -e 's/pixdim1//'`
		strPixdim02=`fslinfo ${strTmpIn} | grep -w pixdim2 | sed -e 's/pixdim2//'`
		strPixdim03=`fslinfo ${strTmpIn} | grep -w pixdim3 | sed -e 's/pixdim3//'`
		strPixdim04=`fslinfo ${strTmpIn} | grep -w pixdim4 | sed -e 's/pixdim4//'`

		# Create variables for new dimensions (matrix size):
		varDim01=`bc <<< ${strDim01}*${varUpInv}`
		varDim02=`bc <<< ${strDim02}*${varUpInv}`
		varDim03=`bc <<< ${strDim03}*${varUpInv}`

		# Create variables for new voxel sizes:
		varPixdim01=`bc <<< ${strPixdim01}*${varUpFac}`
		varPixdim02=`bc <<< ${strPixdim02}*${varUpFac}`
		varPixdim03=`bc <<< ${strPixdim03}*${varUpFac}`

		# Add zero before the decimal point (only necessary when resolution is
		# sub-millimeter):
		varPixdim01="0${varPixdim01}"
		varPixdim02="0${varPixdim02}"
		varPixdim03="0${varPixdim03}"

		echo "---------Image dimensions before upsampling:"
		echo "------------x: ${strDim01}"
		echo "------------y: ${strDim02}"
		echo "------------z: ${strDim03}"
		echo "------------voxel dimension 1: ${strPixdim01}"
		echo "------------voxel dimension 2: ${strPixdim02}"
		echo "------------voxel dimension 3: ${strPixdim03}"
		echo "---------Image dimensions after upsampling:"
		echo "------------x: ${varDim01}"
		echo "------------y: ${varDim02}"
		echo "------------z: ${varDim03}"
		echo "------------voxel dimension 1: ${varPixdim01}"
		echo "------------voxel dimension 2: ${varPixdim02}"
		echo "------------voxel dimension 3: ${varPixdim03}"

		echo "------Creating header"

		# Create header:
		fslcreatehd \
		${varDim01} ${varDim02} ${varDim03} ${strDim04} \
		${varPixdim01} ${varPixdim02} ${varPixdim03} ${strPixdim04} 0 0 0 16 \
		${strTmpIn::-7}_tmp_hdr

		echo "------Upsampling"

		# Upsample current image:
		flirt \
		-in ${strTmpIn} \
		-applyxfm -init /usr/share/fsl/5.0/etc/flirtsch/ident.mat \
		-out ${strTmpIn::-7}_up \
		-paddingsize 0.0 \
		-interp trilinear \
		-ref ${strTmpIn::-7}_tmp_hdr

		# Remove temporary header image:
		rm ${strTmpIn::-7}_tmp_hdr.nii.gz

	done
	#-----------------------------------------------------------------------------


	#-----------------------------------------------------------------------------
	# *** Split 4D files into 3D files

	echo "---Split 4D files"

	for idxIn in $(seq 0 $varNumIn)
	do
		# Define temporary path of current input image:
		strTmpIn="${strInTmp}${aryNiiIn[idxIn]}_up"

	  echo "------Processing ${strTmpIn}"

	  # Basename of output:
	  strTmpOt="${strOtTmp}/${aryNiiIn[idxIn]}_up_vol"

	  # Split:
	  fslsplit ${strTmpIn} ${strTmpOt} -t

	  # Remove intermediate step (upsampled 4D image):
	  rm "${strTmpIn}.nii.gz"
	done
	#-----------------------------------------------------------------------------


done
# -----------------------------------------------------------------------------
