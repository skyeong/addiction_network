
%ROI TWO-SAMPLE 2ND LEVEL
%-----------------------------------------------------------------------
roiName = 'vmpfc_6mm';


% Directory containing Face data
%--------------------------------------------------------------------------
proj_path = '/Volumes/ERIN_MR/Gaming';
fn_xls    = fullfile(proj_path,'subjlist_igd.xlsx');
T = readtable(fn_xls);
Group = T.Group;
subjlist = T.subjname;
nsubj = length(subjlist);


out_dir = fullfile(proj_path,'Results','SecondLevel','twosample',roiName); mkdir(out_dir);


cell1files = cell(0);
cell2files = cell(0);

cnt=1;
for c=1:nsubj
    subjname = subjlist{c};
    if Group(c) == 1 continue; end
    if Group(c) == 2 continue; end
    
    if Group(c) == 0
        controlfile = sprintf(['zscore_' roiName '_' subjname '.nii']);
        cell1files{cnt} = fullfile(proj_path,'Results','staticFC_zmaps', roiName,'rest1', controlfile);
        
    end
    cnt=cnt+1;
end

igd=1;

for c=1:nsubj
    subjname = subjlist{c};
    if Group(c) == 0 continue; end
    
    if Group(c) >= 1
        mildfile = sprintf(['zscore_' roiName '_' subjname '.nii']);
        cell2files{igd} = fullfile(proj_path,'Results','staticFC_zmaps', roiName,'rest1',mildfile);
        
    end
    igd = igd+1;
end



matlabbatch{1}.spm.stats.factorial_design.dir = {out_dir};
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = [cell1files'];
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = [cell2files'];
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
% matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
% matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% spm_jobman('interactive',matlabbatch);
% spm_jobman('run',matlabbatch);

% Parameter Estimation
%--------------------------------------------------------------------------
SPM_mat = fullfile(out_dir,'SPM.mat');
matlabbatch{2}.spm.stats.fmri_est.spmmat = {SPM_mat};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% spm_jobman('interactive',matlabbatch);
% spm_jobman('run',matlabbatch);

% Create Contrasts
%--------------------------------------------------------------------------
matlabbatch{3}.spm.stats.con.spmmat = {SPM_mat};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Control > IGD';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Control < IGD';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;


% spm_jobman('interactive',matlabbatch);
spm_jobman('run',matlabbatch);
