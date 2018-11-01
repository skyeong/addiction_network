addpath('/Users/skyeong/toolbox/iRSFC/utilities/');

%  SETUP DATA PATH AND OUTPUT DIRECTORY
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD/';
data_path = fullfile(proj_path,'Data'); % output directory
output_path= fullfile(proj_path,'Results'); mkdir(output_path);


% Subject List
%--------------------------------------------------------------------------
fn_xls    = fullfile(proj_path,'Demographic','subjlist_igd.xlsx');
T = readtable(fn_xls);
Group = T.Group;
subjlist = T.subjname;
nsubj = length(subjlist);



% Split respect data: respect and afterResp
%--------------------------------------------------------------------------
for c=1:nsubj
    subjname = subjlist{c};
    fprintf('[%03d/%03d] %s is processing...\n',c,nsubj,subjname);
    
    % load self-respect
    %----------------------------------------------------------------------
    fn1 = fullfile(proj_path,'Data',subjname,'rest','swarrest.nii');
    vs1 = spm_vol(fn1);
    
    % remove unnecessary volumes
    vol1 = vs1(3:152);
    IMG1 = spm_read_vols(vol1);
    dir1 = fullfile(proj_path,'Data',subjname,'rest1'); mkdir(dir1);
    fout1 = fullfile(dir1,'swarrest.nii'); delete(fout1);
    vref = vol1(1); vref.n=[1 1];
    vref.fname = fout1;
    spm_write_vols2(vref,IMG1,dir1);
    clear vref vol1 IMG1 fout1
    
    % copy rp_rest.txt files
    f1 = fullfile(proj_path,'Data',subjname,'rest','rp_rest.txt');
    f2 = fullfile(proj_path,'Data',subjname,'rest1','rp_rest.txt');
    copyfile(f1,f2);
 
end