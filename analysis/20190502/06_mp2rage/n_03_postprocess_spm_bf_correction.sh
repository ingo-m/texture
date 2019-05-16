#!/bin/bash


###############################################################################
# Copy results of SPM bias field correction, and remove redundant files.      #
###############################################################################


#------------------------------------------------------------------------------
# *** Define parameters:

# Parent directory:
strPthPrnt="${pacman_data_path}${pacman_sub_id}/nii/"

# Input folder:
strPthIn="mp2rage/02_spm_bf_correction/"

# Output folder:
strPthOut="mp2rage/03_reg/01_in/"

# Array of files:
aryIn=(mp2rage_inv1 \
       mp2rage_pdw \
       mp2rage_t1 \
       mp2rage_uni)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy files

# Loop through files:
for strTmp in ${aryIn[@]}
do
  # Input file:
  strTmpPthIn="${strPthPrnt}${strPthIn}m${strTmp}"

  # Output file:
  strTmpPthOut="${strPthPrnt}${strPthOut}${strTmp}"

  # Change file type to nii.gz:
  fslchfiletype NIFTI_GZ ${strTmpPthIn} ${strTmpPthOut}
done
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Remove redundant files

# Save original path in order to cd back to this path in the end:
strPathOrig=( $(pwd) )

# cd into target directory and create list of images to be removed:
cd "${strPthPrnt}${strPthIn}"

# First list of files to be removed:
aryRm=( $(ls | grep '\<c.*.nii\>') )

# Loop through files:
for strTmp in ${aryRm[@]}
do
  rm ${strTmp}
done

# Second list of files to be removed:
aryRm=( $(ls | grep '\<m.*.nii\>') )

# Loop through files:
for strTmp in ${aryRm[@]}
do
  rm ${strTmp}
done

# cd back to original directory:
cd "${strPathOrig}"
#------------------------------------------------------------------------------
