%--------------------------------------------------------------------------
% Create a 'batch' file for SPM motion correction.
%--------------------------------------------------------------------------
% NOTE: This version is used for creating a moco batch for opposite phase
% polarity data, assuming the file name to be 'func_00'.
%--------------------------------------------------------------------------
% Ingo Marquardt, 2017
%--------------------------------------------------------------------------
%% Define variable parameters:
clear;
% Get environmental variables (for input & output path):
pacman_sub_id = getenv('pacman_sub_id');
pacman_anly_path = getenv('pacman_anly_path');
pacman_data_path = getenv('pacman_data_path');
% Path of the SPM moco directory:
strPathParent = strcat(pacman_data_path, pacman_sub_id, '/nii/spm_reg_op/');
% The number of functional runs:
varNumRuns = 1;
% Name of the 'SPM batch' to be created:
strPathOut = [strPathParent, 'spm_moco_batch.mat'];
%--------------------------------------------------------------------------
%% Prepare input - reference weighting:
% The path to the reference weighting volume:
strPathRefweigth = strcat(strPathParent, 'ref_weighting/');
% The cell array with the file name of the reference weighting volume:
cllPathRefweight = spm_select('ExtList', ...
    strPathRefweigth, ...
    '.nii', ...
    Inf);
cllPathRefweight = cellstr(cllPathRefweight);
cllPathRefweight{1} = strcat(strPathRefweigth, cllPathRefweight{1});
%% Prepare input - file lists of functional time series:
% The paths of the functional runs:
cllPathFunc = cell(1,varNumRuns);
for index_01 = 1:varNumRuns
    if index_01 < 11  % NOTE: Adjusted to account for 'func_00'
        strTmp = strcat(strPathParent, ...
            'func_0', ...
            num2str(index_01 - 1), ...  % NOTE: Adjusted to account for 'func_00'
            '/');
    else
        strTmp = strcat(strPathParent, ...
            'func_', ...
            num2str(index_01 - 1), ...  % NOTE: Adjusted to account for 'func_00'
            '/');
    end
    cllPathFunc{index_01} = spm_select('ExtList', ...
        strTmp, ...
        '.nii', ...
        Inf);
    cllPathFunc{index_01} = cellstr(cllPathFunc{index_01});
    cllPathFunc{index_01} = strcat(strTmp, cllPathFunc{index_01});
end
%--------------------------------------------------------------------------
%% Prepare parameters for motion correction
% Initialise jobs configuration:
% spm_jobman('initcfg');
% Clear old batches:
clear matlabbatch;
% Here we determine the settings for the SPM registrations. See SPM manual
% for details. First, the parameters for the estimation:
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 1.0;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 0.8;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 1.6;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 7;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = ...
    cllPathRefweight;
% Secondly, the parameters for the reslicing:
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 7;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
% The cell array containing the input files. There are now several cell
% arrays that include the input data. We need to combine those into one
% cell array. Note: We only include the functional time series in this
% array, not the reference weighting image. That one is entered separately.
matlabbatch{1}.spm.spatial.realign.estwrite.data = ...
    [cllPathFunc]; %#ok<NBRAK>
%--------------------------------------------------------------------------
%% Save SPM batch file:
save(strPathOut, 'matlabbatch');
%--------------------------------------------------------------------------
%% Perform motion correction
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
