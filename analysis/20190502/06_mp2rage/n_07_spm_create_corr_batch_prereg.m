%--------------------------------------------------------------------------
% The purpose of this script is to create a 'batch' file for SPM
% coregistration of mp2rage images to the mean functional image.
%--------------------------------------------------------------------------
% NOTE: The input images have to be in UNCOMPRESSED nii format for SPM.
%--------------------------------------------------------------------------
% Ingo Marquardt, 2017
%--------------------------------------------------------------------------
%% Define variable parameters:
clear;
% Get environmental variables (for input & output path):
pacman_sub_id = getenv('pacman_sub_id');
pacman_data_path = getenv('pacman_data_path');
% Directory of reference image (combined mean):
strPathRef = strcat(pacman_data_path, pacman_sub_id, '/nii/mp2rage/03_reg/03_prereg/combined_mean/');
% Directory of source image (T1-weighted mp2rage image):
strPathSrc = strcat(pacman_data_path, pacman_sub_id, '/nii/mp2rage/03_reg/03_prereg/mp2rage_t1w/');
% Directory of other images to be registered along source image (T1, PDw,
% INV2):
strPathOtr = strcat(pacman_data_path, pacman_sub_id, '/nii/mp2rage/03_reg/03_prereg/mp2rage_other/');
% Name of the 'SPM batch' to be created:
strPathBatch = strcat(pacman_data_path, pacman_sub_id, '/nii/mp2rage/03_reg/03_prereg/spm_corr_batch.mat');
% Resolution of input images in mm (is assumed to be isotropic):
varRes = 0.45;
%--------------------------------------------------------------------------
%% Prepare input - referenec image:
% The cell array with the file name of the mean M0 image:
cllPathRef = spm_select('ExtList', ...
    strPathRef, ...
    '.nii', ...
    Inf);
% Place the cell array with the M0 image file name in a cell array within
% the original cell array:
cllPathRef = cellstr(cllPathRef);
% Add the parent path:
cllPathRef = strcat(strPathRef, cllPathRef);
%% Prepare input - source image:
% The cell array with the file name of the mean M0 image:
cllPathSrc = spm_select('ExtList', ...
    strPathSrc, ...
    '.nii', ...
    Inf);
% Place the cell array with the M0 image file name in a cell array within
% the original cell array:
cllPathSrc = cellstr(cllPathSrc);
% Add the parent path:
cllPathSrc = strcat(strPathSrc, cllPathSrc);
%% Prepare input - other images:
% The cell array with the file name of the mean M0 image:
cllPathOtr = spm_select('ExtList', ...
    strPathOtr, ...
    '.nii', ...
    Inf);
% Place the cell array with the M0 image file name in a cell array within
% the original cell array:
cllPathOtr = cellstr(cllPathOtr);
% Add the parent path:
cllPathOtr = strcat(strPathOtr, cllPathOtr);
%% Prepare parameters for motion correction
% Clear old batches:
clear matlabbatch;
% Here we determine the settings for the SPM coregistration. See SPM
% manual for details. First, the parameters for the estimation:
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = cllPathRef;
matlabbatch{1}.spm.spatial.coreg.estwrite.source = cllPathSrc;
matlabbatch{1}.spm.spatial.coreg.estwrite.other = cllPathOtr;
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = ...
    [20 * varRes, 10*varRes, 5*varRes, 4*varRes, 3*varRes, 2*varRes, 1*varRes];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = ...
    [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = ...
    [8*varRes, 8*varRes];
% Secondly, the parameters for the reslicing:
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 1;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
%--------------------------------------------------------------------------
%% Save SPM batch file:
save(strPathBatch, 'matlabbatch');
%--------------------------------------------------------------------------
%% Perform registration
% Initialise "job configuration":
spm_jobman('initcfg');
% Run 'job':
spm_jobman('run', matlabbatch);
%--------------------------------------------------------------------------
%% Exit matlab
% Because this matlab scrit gets called from command line, we have to
% include an exit statement:
exit
%--------------------------------------------------------------------------
