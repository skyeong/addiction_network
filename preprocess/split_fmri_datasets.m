addpath('/Users/skyeong/toolbox/iRSFC/utilities/');

%  SETUP DATA PATH AND OUTPUT DIRECTORY
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/respectfmri';
data_path = fullfile(proj_path,'Data'); % output directory
output_path= fullfile(proj_path,'Results'); mkdir(output_path);


% Subject List
%--------------------------------------------------------------------------
fn_xls    = fullfile(proj_path,'Demographic','CRF_Meditation2018.xlsx');
T = readtable(fn_xls);
Group = T.Group;
subjlist = T.subjname;
nsubj = length(subjlist);



% Split respect data: respect and afterResp
%--------------------------------------------------------------------------
for c=1:nsubj
    subjname = subjlist{c};
    fprintf('%s is processing...\n',subjname);
    
    % load self-respect
    %----------------------------------------------------------------------
    fn1 = fullfile(proj_path,'Data',subjname,'respect_all','swarrest.nii');
    vs1 = spm_vol(fn1);
    
    % during respect
    vol1 = vs1(11:385);
    IMG1 = spm_read_vols(vol1);
    dir1 = fullfile(proj_path,'Data',subjname,'respect'); mkdir(dir1);
    fout1 = fullfile(dir1,'swarrest.nii'); delete(fout1);
    vref = vol1(1); vref.n=[1 1];
    vref.fname = fout1;
    spm_write_vols2(vref,IMG1,dir1);
    clear vref vol1 IMG1 fout1
    
    % after respect
    vol2 = vs1(386:end);
    IMG2 = spm_read_vols(vol2);
    dir2 = fullfile(proj_path,'Data',subjname,'afterResp'); mkdir(dir2);
    fout2 = fullfile(dir2,'swarrest.nii'); delete(fout2);
    vref = vol2(1); vref.n=[1 1];
    vref.fname = fout2;
    spm_write_vols2(vref,IMG2,dir2);
    clear vref vol2 IMG2 fout2
    
    
    
    % load self-criticize
    %----------------------------------------------------------------------
    fn2 = fullfile(proj_path,'Data',subjname,'criticize_all','swarrest.nii');
    vs2 = spm_vol(fn2);
    
    % during criticize
    vol1 = vs(11:385);
    IMG1 = spm_read_vols(vol1);
    dir1 = fullfile(proj_path,'Data',subjname,'criticize'); mkdir(dir1);
    fout1 = fullfile(dir1,'swarrest.nii'); delete(fout1);
    vref = vol1(1); vref.n=[1 1];
    vref.fname = fout1;
    spm_write_vols2(vref,IMG1,dir1);
    clear vref vol1 IMG1 fout1
    
    
    % after criticize
    vol2 = vs(386:end);
    IMG2 = spm_read_vols(vol2);
    dir2 = fullfile(proj_path,'Data',subjname,'afterCrit'); mkdir(dir2);
    fout2 = fullfile(dir2,'swarrest.nii'); delete(fout2);
    vref = vol2(1); vref.n=[1 1];
    vref.fname = fout2;
    spm_write_vols2(vref,IMG2,dir2);
    clear vref vol2 IMG2 fout2
    
end