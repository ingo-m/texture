#!/bin/bash


###############################################################################
# Retrieve images from an SPM registration and save them as compressed nii.   #
###############################################################################


# -----------------------------------------------------------------------------
# *** Define session IDs & paths

# Parent directory:
strParent="${pacman_data_path}${pacman_sub_id}/nii/"

# Subdirectories:
strSub01="${strParent}mp2rage/03_reg/03_prereg/"
strSub02="${strParent}mp2rage/03_reg/04_reg/01_in/"

# Input files:

# Names of mp2rage image components (without file suffix):
strT1="mp2rage_t1"
strInv1="mp2rage_inv1"
strPdw="mp2rage_pdw"
strT1w="mp2rage_uni"

# SPM prefix:
strSpm="r"

# SPM directory names:
strSpmDirRef="combined_mean/"
strSpmDirSrc="mp2rage_t1w/"
strSpmDirOtr="mp2rage_other/"
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Copy images

echo "-Copy & compress images"

date

# Crop images:
fslchfiletype NIFTI_GZ ${strSub01}${strSpmDirOtr}${strSpm}${strT1} ${strSub02}${strT1} &
fslchfiletype NIFTI_GZ ${strSub01}${strSpmDirOtr}${strSpm}${strInv1} ${strSub02}${strInv1} &
fslchfiletype NIFTI_GZ ${strSub01}${strSpmDirOtr}${strSpm}${strPdw} ${strSub02}${strPdw} &
fslchfiletype NIFTI_GZ ${strSub01}${strSpmDirSrc}${strSpm}${strT1w} ${strSub02}${strT1w} &
wait

date
echo "-Done"
# -----------------------------------------------------------------------------
