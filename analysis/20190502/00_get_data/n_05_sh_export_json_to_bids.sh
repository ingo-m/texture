#!/bin/bash


###############################################################################
# Copy JSON metadata into the BIDS directory.                                 #
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
# *** Copy metadata for functional images

cp ${strRaw}PROTOCOL_BP_ep3d_bold_pRF_01_LR_SERIES_008_c32.json ${strFunc}func_01.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_pRF_02_RL_SERIES_010_c32.json ${strFunc}func_02.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func_01_RL_SERIES_012_c32.json ${strFunc}func_03.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func_02_RL_SERIES_014_c32.json ${strFunc}func_04.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func_03_RL_SERIES_022_c32.json ${strFunc}func_05.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func_04_RL_SERIES_024_c32.json ${strFunc}func_06.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func_05_RL_SERIES_026_c32.json ${strFunc}func_07.json
cp ${strRaw}PROTOCOL_BP_ep3d_bold_func_06_RL_SERIES_028_c32.json ${strFunc}func_08.json
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy metadata for opposite-phase-polarity SE images

cp ${strRaw}PROTOCOL_cmrr_mbep2d_se_LR_SERIES_005_c32.json ${strSeOp}func_00.json
cp ${strRaw}PROTOCOL_cmrr_mbep2d_se_RL_SERIES_006_c32.json ${strSe}func_00.json
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy metadata for mp2rage images

cp ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_015_c32.json ${strAnat}mp2rage_inv1.json
cp ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_016_c32.json ${strAnat}mp2rage_inv1_phase.json
cp ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_017_c32.json ${strAnat}mp2rage_t1.json
cp ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_018_c32.json ${strAnat}mp2rage_uni.json
cp ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_019_c32.json ${strAnat}mp2rage_pdw.json
cp ${strRaw}PROTOCOL_mp2rage_0.7_iso_p2_SERIES_020_c32.json ${strAnat}mp2rage_pdw_phase.json
#------------------------------------------------------------------------------
