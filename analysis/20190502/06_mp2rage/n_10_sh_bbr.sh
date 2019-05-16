#!/bin/bash


###############################################################################
# The purpose of this script is to perform boundary-based registration using  #
# the FSL epi-reg function.                                                   #
###############################################################################


echo "-BBR registration"


# -----------------------------------------------------------------------------
# *** Define session IDs & paths

# Parent directory:
strParent="${pacman_data_path}${pacman_sub_id}/nii/"

# Subdirectories:
strSub01="${strParent}mp2rage/03_reg/04_reg/01_in/"
strSub02="${strParent}mp2rage/03_reg/04_reg/02_bbr_prep/"
strSub03="${strParent}mp2rage/03_reg/04_reg/03_bbr/"
strSub04="${strParent}mp2rage/03_reg/04_reg/04_inv_bbr/"

# Combined mean:
strCombMean="combined_mean"

# MP2RAGE images:
strT1="mp2rage_t1"
strInv2="mp2rage_inv1"
strPdw="mp2rage_pdw"
strT1w="mp2rage_uni"

# Brain mask for T1w mp2rage image:
strMaskBrainT1w="bbrmask"

# # White matter mask:
# strMaskWm="wm_mask_for_bbr"

# Brain mask for combined mean image:
strMaskBrainCombMean="bbrmask"
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Apply brain mask

echo "---Apply brain mask"

fslmaths \
${strSub01}${strT1w} \
-mul \
${strSub02}${strMaskBrainT1w} \
${strSub02}${strT1w}_brain &

fslmaths \
${strSub01}${strCombMean} \
-mul \
${strSub02}${strMaskBrainCombMean} \
${strSub02}${strCombMean}_brain &

wait

echo "---Done"
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Calculate transformation matrix

echo "---Calculate transformation matrix"

epi_reg \
--epi=${strSub02}${strCombMean}_brain \
--t1=${strSub01}${strT1w} \
--t1brain=${strSub02}${strT1w}_brain \
--out=${strSub03}bbr_reg
#--wmseg=${strSub02}${strMaskWm}

echo "---Done"
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Apply inverse transformation matrix

echo "---Apply inverse transformation matrix"

# Since we would like to register the mp2rage images to the combined mean, we
# need to inverse the transformation.
convert_xfm \
-omat ${strSub04}bbr_reg_inv \
-inverse ${strSub03}bbr_reg.mat

# Apply transformation matrix to T1 image:
flirt \
-interp sinc \
-sincwidth 7 \
-dof 6 \
-in ${strSub01}${strT1} \
-ref ${strSub01}${strCombMean} \
-applyxfm -init ${strSub04}bbr_reg_inv \
-out ${strSub04}${strT1} &

# Apply transformation matrix to INV2 image:
flirt \
-interp sinc \
-sincwidth 7 \
-dof 6 \
-in ${strSub01}${strInv2} \
-ref ${strSub01}${strCombMean} \
-applyxfm -init ${strSub04}bbr_reg_inv \
-out ${strSub04}${strInv2} &

# Apply transformation matrix to PDw image:
flirt \
-interp sinc \
-sincwidth 7 \
-dof 6 \
-in ${strSub01}${strPdw} \
-ref ${strSub01}${strCombMean} \
-applyxfm -init ${strSub04}bbr_reg_inv \
-out ${strSub04}${strPdw} &

# Apply transformation matrix to T1w image:
flirt \
-interp sinc \
-sincwidth 7 \
-dof 6 \
-in ${strSub01}${strT1w} \
-ref ${strSub01}${strCombMean} \
-applyxfm -init ${strSub04}bbr_reg_inv \
-out ${strSub04}${strT1w} &

wait
echo "---Done"
# -----------------------------------------------------------------------------


# To be followed by semi-manual segmentation.
