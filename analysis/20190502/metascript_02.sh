#!/bin/bash


################################################################################
# Metascript for the surface analysis pipeline.                                #
################################################################################


#-------------------------------------------------------------------------------
# ### Get data

# Analysis parent directory:
strPathPrnt="${pacman_anly_path}${pacman_sub_id}/"

echo "-Surface Analysis Pipleline --- ${pacman_sub_id}"
date

echo "---Automatic: Prepare directory tree"
source ${strPathPrnt}00_get_data/n_01_sh_create_folders.sh

if ${pacman_from_bids};
then
	echo "---Skipping DICOM to nii conversion (will look for BIDS data)."
else
	echo "---Automatic: DICOM to nii conversion."
	source ${strPathPrnt}00_get_data/n_02_sh_dcm2nii.sh

	echo "---Automatic: Remove redundant suffix from file name."
	python ${strPathPrnt}00_get_data/n_03_py_rename.py

	if ${pacman_wait};
	then
		echo "---Manual:"
		echo "   Adjust file names in"
                echo "   ${strPathPrnt}00_get_data/n_04_sh_export_nii_to_bids.sh"
		echo "   and in"
                echo "   ${strPathPrnt}00_get_data/n_05_sh_export_json_to_bids.sh"
		echo "   Type 'go' to continue"
		read -r -s -d $'g'
		read -r -s -d $'o'
		date
	else
		:
	fi
fi

#if ${pacman_wait};
#then
#	echo "---Manual:"
#	echo "   Adjust file names in"
#	echo "   ${strPathPrnt}02_feat/n_01_rename.sh"
#	echo "   Type 'go' to continue"
#	read -r -s -d $'g'
#	read -r -s -d $'o'
#	date
#else
#	:
#fi

if ${pacman_from_bids};
then
	:
else
	echo "---Automatic: Export nii to bids."
	source ${strPathPrnt}00_get_data/n_04_sh_export_nii_to_bids.sh
fi

if ${pacman_from_bids};
then
	:
else
	echo "---Automatic: Export json metadata to bids."
	source ${strPathPrnt}00_get_data/n_05_sh_export_json_to_bids.sh
fi

if ${pacman_from_bids};
then
	:
else
	echo "---Automatic: Deface nii data in bids folder."
	python ${strPathPrnt}00_get_data/n_06_py_deface.py
fi

echo "---Automatic: Import nii data from bids."
source ${strPathPrnt}00_get_data/n_07_sh_import_from_bids.sh
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# ### Preprocessing

echo "---Automatic: Reverse order of opposite PE images"
python ${strPathPrnt}01_preprocessing/n_01_py_inverse_order_func_op.py
date

echo "---Automatic: Prepare moco of SE EPI images"
source ${strPathPrnt}01_preprocessing/n_02a_sh_prepare_moco.sh
source ${strPathPrnt}01_preprocessing/n_02b_sh_prepare_moco.sh
date

echo "---Automatic: Prepare moco"
source ${strPathPrnt}01_preprocessing/n_02c_sh_prepare_moco.sh
date

if ${pacman_wait};
then
	echo "---Manual:"
	echo "   Prepare reference weights for motion correction of functional"
	echo "   data and opposite-phase polarity data (based on SE EPI images,"
	echo "   i.e. ~/func_se/func_00 and ~/func_se_op/func_00) and place"
	echo "   them at:"
	echo "       ${pacman_anly_path}${pacman_sub_id}/01_preprocessing/n_03b_${pacman_sub_id}_spm_refweight.nii.gz"
	echo "   and"
	echo "       ${pacman_anly_path}${pacman_sub_id}/01_preprocessing/n_03d_${pacman_sub_id}_spm_refweight_op.nii.gz"
	echo "   Type 'go' to continue"
	read -r -s -d $'g'
	read -r -s -d $'o'
	date
else
	:
fi

# Copy reference weight to spm directory:
fslchfiletype \
   NIFTI \
   ${pacman_anly_path}${pacman_sub_id}/01_preprocessing/n_03b_${pacman_sub_id}_spm_refweight \
   ${pacman_data_path}${pacman_sub_id}/nii/spm_reg/ref_weighting/n_03b_${pacman_sub_id}_spm_refweight

# Copy reference weight for opposite-phase encoding data to spm directory:
fslchfiletype \
   NIFTI \
   ${pacman_anly_path}${pacman_sub_id}/01_preprocessing/n_03d_${pacman_sub_id}_spm_refweight_op \
   ${pacman_data_path}${pacman_sub_id}/nii/spm_reg_op/ref_weighting/n_03d_${pacman_sub_id}_spm_refweight_op

echo "---Automatic: Run SPM motion correction on functional data"
# matlab -nodisplay -nojvm -nosplash -nodesktop \
#   -r "run('/home/john/PhD/GitHub/PacMan/analysis/20180118_distcor_func/01_preprocessing/n_06a_spm_create_moco_batch.m');"
/opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${pacman_anly_path}${pacman_sub_id}/01_preprocessing/n_03a_spm_create_moco_batch.m
date

echo "---Automatic: Run SPM motion correction on opposite-phase polarity data"
# matlab -nodisplay -nojvm -nosplash -nodesktop \
#   -r "run('/home/john/PhD/GitHub/PacMan/analysis/20180118_distcor_func/01_preprocessing/n_06c_spm_create_moco_batch_op.m');"
/opt/spm12/run_spm12.sh /opt/mcr/v85/ batch ${pacman_anly_path}${pacman_sub_id}/01_preprocessing/n_03c_spm_create_moco_batch_op.m
date

echo "---Automatic: Copy moco results"
source ${strPathPrnt}01_preprocessing/n_04a_sh_postprocess_moco.sh
date

echo "---Automatic: Copy moco results of SE EPI images"
source ${strPathPrnt}01_preprocessing/n_04b_sh_postprocess_moco.sh
date

echo "---Automatic: Copy moco results of opposite-phase polarity SE EPI images"
source ${strPathPrnt}01_preprocessing/n_04c_sh_postprocess_moco.sh
date

echo "---Automatic: Calculate fieldmaps"
source ${strPathPrnt}01_preprocessing/n_05a_sh_fsl_topup.sh
date

echo "---Automatic: Apply TOPUP on functional data"
source ${strPathPrnt}01_preprocessing/n_06a_fsl_applytopup.sh
date

echo "---Automatic: Apply TOPUP on SE EPI data"
source ${strPathPrnt}01_preprocessing/n_06b_fsl_applytopup.sh
date

echo "---Automatic: Create mean undistorted SE EPI image."
source ${strPathPrnt}01_preprocessing/n_07_sh_mean_se.sh
date
#-------------------------------------------------------------------------------


