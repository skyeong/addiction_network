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
% Collect files for each group
%--------------------------------------------------------------------------
fmri0 = cell(0);  cnt0=1;
fmri1 = cell(0);  cnt1=1;
fmri2 = cell(0);  cnt2=1;

fmri_dir=fullfile(proj_path,'Results','staticFC_zmaps','fALFF','rest1');
for c=1:nsubj
    subjname = subjlist{c};
    switch Group(c)
        case 0
            fmri0{cnt0} = fullfile(fmri_dir,['zscore_fALFF_', subjname, '.nii']);
            cnt0=cnt0+1;
        case 1
            fmri1{cnt1} = fullfile(fmri_dir,['zscore_fALFF_', subjname, '.nii']);
            cnt1=cnt1+1;
        case 2
            fmri2{cnt2} = fullfile(fmri_dir,['zscore_fALFF_', subjname, '.nii']);
            cnt2=cnt2+1;
    end
end


%--------------------------------------------------------------------------
% FMRI - create design matrix
%--------------------------------------------------------------------------
clear matlabbatch;
outdir=fullfile(proj_path,'Group_Stat','fALFF'); mkdir(outdir);
matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(outdir);
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans = [fmri0'];
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(2).scans = [fmri1'];
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(3).scans = [fmri2'];
matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = fullfile(spm('dir'),'apriori','mask_cor_subcor.nii');
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
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
