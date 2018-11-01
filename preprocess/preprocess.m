addpath('/Users/skyeong/matlabwork/spm12');


% fMRI parameter
%--------------------------------------------------------------------------
TR         = 2;  % 800ms



% Directory containing Face data
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD';
fn_xls    = fullfile(proj_path,'Demographic','IGD_subjlist.xlsx');
T = readtable(fn_xls);

data_path = fullfile(proj_path,'Data');
subjlist = T.subjname;
nsubj = length(subjlist);

% Initialise SPM
%--------------------------------------------------------------------------
spm('Defaults','fMRI');
spm_jobman('initcfg');


fmriName = 'rest';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPATIAL PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
for c=20:nsubj
    subjname = subjlist{c};
    fprintf('[%03d/%03d] %s (%g min)\n',c,nsubj,subjname,toc/60)
    clear matlabbatch
    
    % Select functional and structural scans
    %----------------------------------------------------------------------
    f0 = spm_select('ExtFPList', fullfile(data_path,subjname,fmriName), '^rest.*\.nii$');
    a = spm_select('ExtFPList', fullfile(data_path,subjname,'anat'  ), '^anat.*\.nii$');
    f = f0(3:152,:);
    
    % Get number of slices
    vo = spm_vol(f(1,:));
    nslices    = vo.dim(3);
    if rem(nslices,2)
        sliceOrder = [1:2:nslices 2:2:nslices];
    else
        sliceOrder = [2:2:nslices 1:2:nslices];
    end
    ref_slice = floor(sliceOrder/2);
    
    
    % Realign
    %----------------------------------------------------------------------
    matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = cellstr(f);
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    
    
    % Slice Timing Correction
    %----------------------------------------------------------------------
    matlabbatch{2}.spm.temporal.st.scans{1} = cellstr(spm_file(f,'prefix','r'));
    matlabbatch{2}.spm.temporal.st.nslices = nslices;
    matlabbatch{2}.spm.temporal.st.tr = TR;
    matlabbatch{2}.spm.temporal.st.ta = TR-TR/nslices;
    matlabbatch{2}.spm.temporal.st.so = sliceOrder;
    matlabbatch{2}.spm.temporal.st.refslice = 15;
    
    
    % Coregister
    %----------------------------------------------------------------------
    matlabbatch{3}.spm.spatial.coreg.estimate.ref    = cellstr(spm_file(f0(1,:),'prefix','mean'));
    matlabbatch{3}.spm.spatial.coreg.estimate.source = cellstr(a);
    
    
    % Normalise: Estimate and Write
    %----------------------------------------------------------------------
    matlabbatch{4}.spm.spatial.normalise.estwrite.subj.vol = cellstr(a);
    matlabbatch{4}.spm.spatial.normalise.estwrite.subj.resample = [cellstr(spm_file(f,'prefix','ar'));cellstr(a)];
    matlabbatch{4}.spm.spatial.normalise.estwrite.eoptions.tpm = {fullfile(spm('dir'),'tpm','TPM.nii')};
    matlabbatch{4}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70; 78 76 85];
    matlabbatch{4}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
    
    
    % Smooth
    %----------------------------------------------------------------------
    matlabbatch{5}.spm.spatial.smooth.data = cellstr(spm_file(f,'prefix','war'));
    matlabbatch{5}.spm.spatial.smooth.fwhm = [6 6 6];
    
    % spm_jobman('interactive',matlabbatch);
    spm_jobman('run',matlabbatch);
end