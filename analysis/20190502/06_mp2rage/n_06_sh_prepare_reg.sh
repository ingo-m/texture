#!/bin/bash


###############################################################################
# The purpose of this script is to prepare the mp2rage to combined mean       #
# registration pipeline. As a preparation, the mp2rage component images have  #
# to be placed in the first subdirectory (i.e. ".../01_in/"), with the        #
# following file names: mp2rage_t1, mp2rage_inv1, mp2rage_pdw, mp2rage_uni.   #
# Also, the mean EPI image and a brain mask need to be provided (see previous #
# steps).                                                                     #
###############################################################################


# -----------------------------------------------------------------------------
# *** Define session IDs & paths

# Parent directory:
strParent="${pacman_data_path}${pacman_sub_id}/nii/"

# Subdirectories:
strSub01="${strParent}mp2rage/03_reg/01_in/"
strSub02="${strParent}mp2rage/03_reg/02_brainmask/"
strSub03="${strParent}mp2rage/03_reg/03_prereg/"

# Combined mean image:
strCombmean="combined_mean"

# Brain mask:
strBrainMsk="n_04b_${pacman_sub_id}_pwd_brainmask"

# Names of mp2rage image components (without file suffix):
strT1="mp2rage_t1"
strInv2="mp2rage_inv1"
strPdw="mp2rage_pdw"
strT1w="mp2rage_uni"

# SPM directory names:
strSpmDirRef="combined_mean/"
strSpmDirOtr="mp2rage_other/"
strSpmDirSrc="mp2rage_t1w/"
# -----------------------------------------------------------------------------


echo "-Prepare pre-registration"


# -----------------------------------------------------------------------------
# *** Brain masking

echo "------Apply brain mask"

# Brain masking T1 image:
fslmaths \
${strSub01}${strT1} \
-mul \
${strSub02}${strBrainMsk} \
${strSub02}${strT1} &

# Brain masking INV2 image:
fslmaths \
${strSub01}${strInv2} \
-mul \
${strSub02}${strBrainMsk} \
${strSub02}${strInv2} &

# Brain masking PDw image:
fslmaths \
${strSub01}${strPdw} \
-mul \
${strSub02}${strBrainMsk} \
${strSub02}${strPdw} &

# Brain masking T1w image:
fslmaths \
${strSub01}${strT1w} \
-mul \
${strSub02}${strBrainMsk} \
${strSub02}${strT1w} &

wait

# Remove input files:
echo "------Removing input files"
rm ${strSub01}${strT1}.nii.gz
rm ${strSub01}${strInv2}.nii.gz
rm ${strSub01}${strPdw}.nii.gz
rm ${strSub01}${strT1w}.nii.gz

echo "---Done"
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# *** Copy results into SPM directory for preregistration

echo "---Copy results into SPM directory for preregistration"

# Copy mp2rages:
fslchfiletype NIFTI ${strSub02}${strT1w} ${strSub03}${strSpmDirSrc}${strT1w} &
fslchfiletype NIFTI ${strSub02}${strT1} ${strSub03}${strSpmDirOtr}${strT1} &
fslchfiletype NIFTI ${strSub02}${strInv2} ${strSub03}${strSpmDirOtr}${strInv2} &
fslchfiletype NIFTI ${strSub02}${strPdw} ${strSub03}${strSpmDirOtr}${strPdw} &

# Copy combined mean:
fslchfiletype NIFTI ${strSub01}${strCombmean} ${strSub03}${strSpmDirRef}${strCombmean} &

wait

# Remove input files:
echo "------Removing input files"
rm ${strSub02}${strT1}.nii.gz
rm ${strSub02}${strInv2}.nii.gz
rm ${strSub02}${strT1w}.nii.gz
rm ${strSub02}${strPdw}.nii.gz

echo "---Done"
# -----------------------------------------------------------------------------
