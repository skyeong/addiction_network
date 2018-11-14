warning('off','all');


%--------------------------------------------------------------------------
% Directory containing preprocessed IGD dataset
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD';
fn_xls    = fullfile(proj_path,'Demographic','subjlist_igd.xlsx');
T = readtable(fn_xls);
Group = T.Group;
subjlist = T.subjname;
nsubj = length(subjlist);



%--------------------------------------------------------------------------
% Load TIV
%--------------------------------------------------------------------------
fn_tiv = fullfile(proj_path,'Results','TIV.csv');
TIV = readtable(fn_tiv);
idxOrd = [find(Group==0); find(Group==1); find(Group==2)];

%--------------------------------------------------------------------------
% Collect files for each group
%--------------------------------------------------------------------------
vbm0 = cell(0);  cnt0=1;
vbm1 = cell(0);  cnt1=1;
vbm2 = cell(0);  cnt2=1;


vbm_dir=fullfile(proj_path,'CAT12');
for c=1:nsubj
    subjname = subjlist{c};
    switch Group(c)
        case 0
            vbm0{cnt0} = fullfile(vbm_dir,subjname,'anat','mri','smwp1anat.nii');
            cnt0=cnt0+1;
        case 1
            vbm1{cnt1} = fullfile(vbm_dir,subjname,'anat','mri','smwp1anat.nii');
            cnt1=cnt1+1;
        case 2
            vbm2{cnt2} = fullfile(vbm_dir,subjname,'anat','mri','smwp1anat.nii');
            cnt2=cnt2+1;
    end
end


%--------------------------------------------------------------------------
% FMRI - create design matrix
%--------------------------------------------------------------------------
clear matlabbatch;
outdir=fullfile(proj_path,'Group_Stat','CAT12'); mkdir(outdir);
matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(outdir);
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans = [vbm0'];
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(2).scans = [vbm1'];
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(3).scans = [vbm2'];
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = TIV.Total(idxOrd);
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'TIV';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tma.athresh = 0.2;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
% matlabbatch{1}.spm.stats.factorial_design.masking.em = fullfile(spm('dir'),'apriori','mask_cor_subcor.nii');
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
% spm_jobman('interactive',matlabbatch);
spm_jobman('run',matlabbatch);



% Step2: Parameter Estimate
%--------------------------------------------------------------------------
clear matlabbatch;
fn_SPM = fullfile(outdir,'SPM.mat');
matlabbatch{1}.spm.stats.fmri_est.spmmat = {fn_SPM};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run',matlabbatch);




% Step3: Create contrast
%--------------------------------------------------------------------------
clear matlabbatch;
matlabbatch{1}.spm.stats.con.spmmat = {fn_SPM};
matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = 'Main effect (group)';
matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights = [1 -1 0; 0 1 -1];
matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 1;
spm_jobman('run',matlabbatch);
