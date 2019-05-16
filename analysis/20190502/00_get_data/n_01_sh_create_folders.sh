#!/bin/bash


###############################################################################
# Create subject's directory tree for the PacMan analusis pipeline.           #
###############################################################################


# -----------------------------------------------------------------------------
# *** Define parameters:

# Get session ID (from environmental variable, which is defined in metascript):
str_session_ID="${pacman_sub_id}"

# Get data directory (from environmental variable, which is defined in
# metascript):
str_path_parent="${pacman_data_path}${str_session_ID}"

# Nii directory (main analysis directory):
str_nii="${str_path_parent}/nii"

# CBS directory (depth sampling):
str_cbs="${str_path_parent}/cbs"

# Functional runs (input):
ary_run_IDs=(func_01 \
             func_02 \
             func_03 \
             func_04 \
             func_05 \
             func_06 \
             func_07 \
             func_08)
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Create session parent directory

# Check whether directory already exists:
if [ ! -d "${str_path_parent}" ];
then

	echo "Creating parent directory for ${str_session_ID}"
	mkdir "${str_path_parent}"

else

	echo "Directory ${str_session_ID} already exists."

fi
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Create nii directory (main analysis directory)

# Number of runs:
# var_include=${#ary_run_IDs[@]}

# Check whether directory already exists:
if [ ! -d "${str_nii}" ];
then

	echo "Creating analysis directory ${str_nii}"

	mkdir "${str_nii}/"

	mkdir "${str_nii}/feat_level_1_prf"

	mkdir "${str_nii}/feat_level_1_comb"
	mkdir "${str_nii}/feat_level_2_comb"

	mkdir "${str_nii}/func"
	mkdir "${str_nii}/func_distcorField"
	mkdir "${str_nii}/func_reg"
	mkdir "${str_nii}/func_reg_tsnr"
	mkdir "${str_nii}/func_reg_distcorUnwrp"
	mkdir "${str_nii}/func_reg_averages"

	mkdir "${str_nii}/func_se"
	mkdir "${str_nii}/func_se_reg"
	mkdir "${str_nii}/func_se_op"
	mkdir "${str_nii}/func_se_op_inv"
	mkdir "${str_nii}/func_se_op_inv_reg"
	mkdir "${str_nii}/func_se_merged"

	mkdir "${str_nii}/mp2rage"

	mkdir "${str_nii}/mp2rage/01_orig"
	mkdir "${str_nii}/mp2rage/02_spm_bf_correction"
	mkdir "${str_nii}/mp2rage/03_reg"
	mkdir "${str_nii}/mp2rage/03_reg/01_in"
	mkdir "${str_nii}/mp2rage/03_reg/02_brainmask"
	mkdir "${str_nii}/mp2rage/03_reg/03_prereg"
	mkdir "${str_nii}/mp2rage/03_reg/03_prereg/combined_mean"
	mkdir "${str_nii}/mp2rage/03_reg/03_prereg/mp2rage_other"
	mkdir "${str_nii}/mp2rage/03_reg/03_prereg/mp2rage_t1w"
	mkdir "${str_nii}/mp2rage/03_reg/04_reg"
	mkdir "${str_nii}/mp2rage/03_reg/04_reg/01_in"
	mkdir "${str_nii}/mp2rage/03_reg/04_reg/02_bbr_prep"
	mkdir "${str_nii}/mp2rage/03_reg/04_reg/03_bbr"
	mkdir "${str_nii}/mp2rage/03_reg/04_reg/04_inv_bbr"
	mkdir "${str_nii}/mp2rage/04_seg"

	mkdir "${str_nii}/raw_data"

	mkdir "${str_nii}/retinotopy"
	mkdir "${str_nii}/retinotopy/mask"
	mkdir "${str_nii}/retinotopy/pRF_results"
	mkdir "${str_nii}/retinotopy/pRF_results_up"
	mkdir "${str_nii}/retinotopy/pRF_stimuli"
	mkdir "${str_nii}/retinotopy/extrasession"

	# Create subfolders for SPM - func across runs moco:
	mkdir "${str_nii}/spm_reg"
	mkdir "${str_nii}/spm_reg/ref_weighting"
	for index_1 in ${ary_run_IDs[@]}
	do
		str_tmp_1="${str_nii}/spm_reg/${index_1}"
		mkdir "${str_tmp_1}"
	done

	# Create SPM subfolder for SE run:
	mkdir "${str_nii}/spm_reg/func_00"

	# Create SPM subfolders for SE run - opposite-phase-polarity:
	mkdir "${str_nii}/spm_reg_op"
	mkdir "${str_nii}/spm_reg_op/func_00"
	mkdir "${str_nii}/spm_reg_op/ref_weighting"

	mkdir "${str_nii}/spm_reg_reference_weighting"
	mkdir "${str_nii}/spm_reg_moco_params"

	mkdir "${str_nii}/stat_maps_comb"
	mkdir "${str_nii}/stat_maps_comb_up"

else

	echo "Analysis directory ${str_nii} already exists."

fi
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Create cbs directory (depth sampling)

# Check whether directory already exists:
if [ ! -d "${str_cbs}" ];
then

	echo "Creating depth sampling directory ${str_cbs}"

	mkdir "${str_cbs}"

	mkdir "${str_cbs}/lh"
	mkdir "${str_cbs}/lh_era"
	mkdir "${str_cbs}/lh_era/bright_square"
	mkdir "${str_cbs}/lh_era/full_screen"

  mkdir "${str_cbs}/rh"
	mkdir "${str_cbs}/rh_era"
	mkdir "${str_cbs}/rh_era/bright_square"
	mkdir "${str_cbs}/rh_era/full_screen"

else

	echo "Depth sampling directory ${str_cbs} already exists."

fi
# -----------------------------------------------------------------------------
