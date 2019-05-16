#!/bin/bash


###############################################################################
# Import data from BIDS folder structure into PacMan analysis pipeline.       #
###############################################################################


#------------------------------------------------------------------------------
# *** Define paths:

# Parent directory:
strPthPrnt="${pacman_data_path}${pacman_sub_id}/nii"

# BIDS directory:
strBidsDir="${pacman_data_path}BIDS/"

# BIDS directory containing functional data:
strBidsFunc="${strBidsDir}${pacman_sub_id_bids}/func/"

# Destination directory for functional data:
strFunc="${strPthPrnt}/func/"

# BIDS directory containing same-phase-polarity SE images:
strBidsSe="${strBidsDir}${pacman_sub_id_bids}/func_se/"

# Destination directory for same-phase-polarity SE images:
strSe="${strPthPrnt}/func_se/"

# BIDS directory containing opposite-phase-polarity SE images:
strBidsSeOp="${strBidsDir}${pacman_sub_id_bids}/func_se_op/"

# Destination directory for opposite-phase-polarity SE images:
strSeOp="${strPthPrnt}/func_se_op/"

# BIDS directory containing mp2rage images:
strBidsAnat="${strBidsDir}${pacman_sub_id_bids}/anat/"

# Destination directory for mp2rage images:
strAnat="${strPthPrnt}/mp2rage/01_orig/"
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy functional data

cp -r ${strBidsFunc}*.nii.gz ${strFunc}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy opposite-phase-polarity SE images

cp -r ${strBidsSe}*.nii.gz ${strSe}
cp -r ${strBidsSeOp}*.nii.gz ${strSeOp}
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# *** Copy mp2rage images

cp -r ${strBidsAnat}*.nii.gz ${strAnat}
#------------------------------------------------------------------------------
