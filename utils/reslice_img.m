% addpath('/Users/skyeong/matlabwork/spm12');

% source = '/Volumes/JetDrive/data/RM_kdh/parkinson/ROIs/cerebellum.nii';
% target = '/Volumes/JetDrive/data/RM_kdh/parkinson/data_pt/006/pet/swpet.nii';
source = 'shen_268.nii';
target = '/Users/skyeong/data/respectfmri/Results/staticFC_zmaps/MPFC_6mm/baseline/zscore_MPFC_6mm_CON01_SSJ.nii';
fns = char(target,source);

flags = struct('interp',0,'mask',0,'mean',0,'which',1,'wrap',[0 0 0]');
spm_reslice(fns,flags);


% sources = spm_select('FPList',fullfile(DATApath,'DARTEL','gm'), '^smwrc1.*\.nii');
% for i=1:length(sources),
%     source = sources(i,:);
%     fns = char(target,source);
%
%     flags = struct('interp',0,'mask',0,'mean',0,'which',1,'wrap',[0 0 0]');
%     spm_reslice(fns,flags);
% end
