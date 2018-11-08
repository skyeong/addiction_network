warning('off','all');



% Directory containing Face data
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/respectfmri';
fn_xls    = fullfile(proj_path,'Demographic','CRF_Meditation2018.xlsx');
T = readtable(fn_xls);
Group = T.Group;
subjlist = T.subjname;
nsubj = length(subjlist);



% Atlas Name
%--------------------------------------------------------------------------
atlasName = 'AAL'; nrois=116;
% atlasName = 'shen_268'; nrois=268;

fn_atlas = fullfile(proj_path,'Atlas',[atlasName '.nii']);
vo_atlas = spm_vol(fn_atlas);
ATLAS = spm_read_vols(vo_atlas);


output = table();
for c=1:nsubj
    subjname = subjlist{c};
    matfile = sprintf('network_%s.mat',subjname);
    fn = fullfile(proj_path,'Results','staticFC_Aij',atlasName,'rest',matfile);
    load(fn);
    
    % Get network backbone
    corrD = graph(1-R);
    subG  = minspantree(corrD);
    subG.Edges.Weight = 1-subG.Edges.Weight;
    mst = compute_mst_measures(subG);
    
    mst.subjname = {subjname};
    mst.taskname=cellstr(taskname{i});
    mst.Group = Group(c);
    output = [output; mst];
end