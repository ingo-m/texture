#!/bin/bash


###############################################################################
# Upsample pRF results.                                                       #
###############################################################################


# -----------------------------------------------------------------------------
# *** Define parameters

# Input directory:
strPthIn="${pacman_data_path}${pacman_sub_id}/nii/retinotopy/pRF_results/"

# Output directory:
strPthOut="${pacman_data_path}${pacman_sub_id}/nii/retinotopy/pRF_results_up/"

# Upsampling factor (e.g. 0.5 for half the previous voxel size, 0.25 for a
# quater of the previous voxel size):
varUpFac=0.5
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Upsample images

echo "-Upsampling of pRF results"

# Calculate inverse of upsampling factor (for caculation of new matrix size):
varUpInv=`bc <<< 1/${varUpFac}`

# Save original path in order to cd back to this path in the end:
strPathOrig=( $(pwd) )

# cd into target directory and create list of images to be processed, only
# taking into account compressed nii files containing pRF results:
cd "${strPthIn}"
aryIn=( $(ls | grep pRF_results_ | grep .nii) )

# Check number of files to be processed:
varNumIn=${#aryIn[@]}

# Since indexing starts from zero, we subtract one:
varNumIn=$((varNumIn - 1))

for idx01 in $(seq 0 $varNumIn)
do
	# Define temporary path of current input image:
	strTmpIn="${strPthIn}${aryIn[idx01]::-7}"

	# Temporary output path:
	strTmpOut="${strPthOut}${aryIn[idx01]::-7}"

	echo "--------------------------------------------------------------------"
	echo "------Processing ${aryIn[idx01]}"
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
	${strTmpIn}_tmp_hdr

	echo "------Upsampling"

	# Upsample current image:
	flirt \
	-in ${strTmpIn} \
	-applyxfm -init /usr/share/fsl/5.0/etc/flirtsch/ident.mat \
	-out ${strTmpOut} \
	-paddingsize 0.0 \
	-interp trilinear \
	-ref ${strTmpIn}_tmp_hdr

	# Remove temporary header image:
	rm ${strTmpIn}_tmp_hdr.nii.gz

done

# cd back to original directory:
cd "${strPathOrig}"
# -----------------------------------------------------------------------------
