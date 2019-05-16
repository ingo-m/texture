#!/bin/bash


#-------------------------------------------------------------------------------
# ### Prepare config file for pRF analysis

# Get path of template config file from environmental variables:
str_path="${pacman_anly_path}${pacman_sub_id}/07_pRF/"

# Replace path placeholders in config files with:
NEW_DATA_PATH="${pacman_data_path}"
NEW_SUBJECT_ID="${pacman_sub_id}"
NEW_CPU_USAGE="${pacman_cpu}"

# Copy the existing fsf file:
cp ${str_path}02b_pRF_config.csv ${str_path}02b_pRF_config_sed.csv

# Replace placeholders:
sed -i "s|PLACEHOLDER_FOR_DATA_PATH|${NEW_DATA_PATH}|g" ${str_path}02b_pRF_config_sed.csv
sed -i "s|PLACEHOLDER_FOR_SUBJECT_ID|${NEW_SUBJECT_ID}|g" ${str_path}02b_pRF_config_sed.csv
sed -i "s|PLACEHOLDER_FOR_CPU_USAGE|${NEW_CPU_USAGE}|g" ${str_path}02b_pRF_config_sed.csv
#-------------------------------------------------------------------------------
