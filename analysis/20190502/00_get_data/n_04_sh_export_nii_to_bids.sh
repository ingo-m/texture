#!/bin/bash


###############################################################################
# The purpose of this script is to copy the 'original' nii images, after      #
# DICOM to nii conversion, and reorient them to standard orientation. The     #
# contents of this script have to be adjusted individually for each session,  #
# as the original file names may differ from session to session.              #
###############################################################################


#------------------------------------------------------------------------------
# *** Define paths:

# Parent directory:
strPthPrnt="${pacman_data_path}${pacman_sub_id}/nii"

# BIDS directory:
strBidsDir="${pacman_data_path}BIDS/"

# 'Raw' data directory, containing nii images after DICOM->nii conversion:
strRaw="${strPthPrnt}/raw_data/"

# Destination directory for functional data:
strFunc="${strBidsDir}${pacman_sub_id_bids}/func/"

# Destination directory for same-phase-polarity SE images:
strSe="${strBidsDir}${pacman_sub_id_bids}/func_se/"

# Destination directory for opposite-phase-polarity SE images:
strSeOp="${strBidsDir}${pacman_sub_id_bids}/func_se_op/"

# Destination directory for mp2rage images:
strAnat="${strBidsDir}${pacman_sub_id_bids}/anat/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Create BIDS directory tree

# Check whether the session directory already exists:
if [ ! -d "${strBidsDir}${pacman_sub_id_bids}" ];
then
	echo "Create BIDS directory for ${strBidsDir}${pacman_sub_id_bids}"

	# Create BIDS subject parent directory:
	mkdir "${strBidsDir}${pacman_sub_id_bids}"

	# Create BIDS directory tree:
	mkdir "${strAnat}"
	mkdir "${strFunc}"
	mkdir "${strSe}"
	mkdir "${strSeOp}"
else
	echo "Directory for ${strBidsDir}${pacman_sub_id_bids} does already exist."
fi
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy functional data

fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func_01_RL_SERIES_008_c32 ${strFunc}func_01
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func_02_RL_SERIES_010_c32 ${strFunc}func_02
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func_03_RL_SERIES_018_c32 ${strFunc}func_03
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func_04_RL_SERIES_020_c32 ${strFunc}func_04
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func_05_RL_SERIES_022_c32 ${strFunc}func_05
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func_06_RL_SERIES_024_c32 ${strFunc}func_06
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func_07_RL_SERIES_026_c32 ${strFunc}func_07
fslreorient2std ${strRaw}PROTOCOL_BP_ep3d_bold_func_08_RL_SERIES_028_c32 ${strFunc}func_08
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy opposite-phase-polarity SE images

fslreorient2std ${strRaw}PROTOCOL_cmrr_mbep2d_se_LR_SERIES_005_c32 ${strSeOp}func_00
fslreorient2std ${strRaw}PROTOCOL_cmrr_mbep2d_se_RL_SERIES_006_c32 ${strSe}func_00
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy mp2rage images

fslreorient2std ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_011_c32 ${strAnat}mp2rage_inv1
fslreorient2std ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_012_c32 ${strAnat}mp2rage_inv1_phase
fslreorient2std ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_013_c32 ${strAnat}mp2rage_t1
fslreorient2std ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_014_c32 ${strAnat}mp2rage_uni
fslreorient2std ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_015_c32 ${strAnat}mp2rage_pdw
fslreorient2std ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_016_c32 ${strAnat}mp2rage_pdw_phase
#------------------------------------------------------------------------------
