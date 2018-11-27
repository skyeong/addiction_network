addpath(genpath('/Users/skyeong/matlabscripts/toolbox/GenLouvain2.1'));
addpath(genpath('/Users/skyeong/connectome/bct'));
addpath(genpath('/Users/skyeong/matlabscripts/toolbox/utils'));
clear all; tic;


% Atlas Name
%--------------------------------------------------------------------------
atlasName = 'AAL'; nrois=90;
% atlasName = 'shen_268'; nrois=268;
% atlasName = 'HarvardOxford'; nrois=112;



% Directory containing Face data
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD';
fn_xls    = fullfile(proj_path,'Demographic','subjlist_igd.xlsx');
T = readtable(fn_xls);
Group = T.Group;
subjlist = T.subjname;
nsubj = length(subjlist);


% Group Averaging Adjacency Matrix
%--------------------------------------------------------------------------
clear A;
allR = zeros(nsubj,nrois,nrois);
for c=1:nsubj
    
    subjname = subjlist{c};
    matfile = sprintf('network_%s.mat',subjname);
    
    fn = fullfile(proj_path,'Results','staticFC_Aij',atlasName,'rest1',matfile);
    load(fn);
    allR(c,:,:) = R;
end
A = squeeze(mean(allR));
A(A<0.0)=0;
% triU = ones(nrois,nrois);
% triU = triu(triU,1);
% idxU = find(triU>0);
% rankedr = sort(A(idxU),'descend');
% thr = rankedr(round(length(idxU)*0.15));
% A(A<thr)=0;


%  Example 2: Categorical Multislice Matrix
%--------------------------------------------------------------------------

niter=1000;
Q = zeros(niter,1);
Ci = '';
for i=1:niter
    [ci_,q_] = modularity_louvain_und(A);
    Q(i) = q_;
    Ci{i} = ci_;
end



%  MODULE SIMILARITY (WITHIN GROUP 1)
%--------------------------------------------------------------------------

fprintf('    : module similarity (within group 1) (%.1f min) ...\n',toc/60);
NMI = zeros(niter,niter);

for ci=1:niter
    ci_i = Ci{ci};
    for cj=(ci+1):niter
        ci_j = Ci{cj};
        mutualinfo = nmi(ci_i, ci_j);
        NMI(ci,cj) = mutualinfo;
    end
end
NMI = NMI + NMI';



% Find the Best Partition
%--------------------------------------------------------------------------
[val, idx] = max(mean(NMI));
fprintf('    : modularity (Q) = %.4f\n', Q(idx));
ci_best = Ci{idx};
Q_best  = Q(idx);


if 1
    % Writing Images of Modular Architecture
    %----------------------------------------------------------------------
    vo_atlas = spm_vol(fullfile(proj_path,'Atlas',[atlasName '.nii']));
    MODULEpath = fullfile(proj_path,'Results','modularity',atlasName,'modular_4m'); mkdir(MODULEpath);
    
    cond_name = 'baseline';
    
    for i=1:max(ci_best)
        Ci1 = zeros(nrois,1);
        idx = ci_best==i;
        Ci1(idx) = i;
        fn_out = sprintf('%s_m%02d.nii',cond_name,i);
        network_analysis_write2img(MODULEpath, fn_out, vo_atlas, [1:nrois], Ci1, 0);
    end
end


fn_out = fullfile(proj_path,'Results','modularity',atlasName,'modularity_4m.mat');
save(fn_out);

