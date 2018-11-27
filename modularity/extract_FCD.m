addpath(genpath('/Users/skyeong/connectome/bct'));
addpath(genpath('/Users/skyeong/matlabscripts/toolbox/utils'));
clear all; tic;




% Directory containing Face data
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD';
fn_xls    = fullfile(proj_path,'Demographic','subjlist_igd.xlsx');
T = readtable(fn_xls);
Group = T.Group;
subjlist = T.subjname;
nsubj = length(subjlist);


% Atlas Name
%--------------------------------------------------------------------------
atlasName = 'AAL'; nrois=90;
% atlasName = 'shen_268'; nrois=268;
% atlasName = 'HarvardOxford'; nrois=112;



% Load Best Partition
%--------------------------------------------------------------------------
fn_module = fullfile(proj_path,'Results','modularity',atlasName,'modularity_4m.mat');
load(fn_module,'ci_best');
nci = max(ci_best);


% Load fmri data
%--------------------------------------------------------------------------
FCD = zeros(4,4,nsubj);
output=table();
for c=1:nsubj
    subjname = subjlist{c};
    filedir = fullfile(proj_path,'Results','staticFC_Aij',atlasName);
    matfile = sprintf('network_%s.mat',subjname);
    fn = fullfile(filedir,'rest1',matfile);
    load(fn);
    
    T1 = table();
    T1.subjid = c;
    T1.subjname = {subjlist{c}};
    T1.Group = T.Group(c);
    
    for i=1:nci
        idx_i=find(ci_best==i);
        for j=i:nci
            idx_j=find(ci_best==j);
            
            dat = R(idx_i,idx_j);
            if i==j
                dat(eye(length(dat))==1)=[];
            end
            fcd = nanmean(dat(:));
            varName = sprintf('fcd%d%d',i,j);
            T1.(varName) = fcd;
        end
    end
    output=[output; T1];
end
fn_out = fullfile('~/Desktop/FCD.csv');
writetable(output,fn_out);



%--------------------------------------------------------------------------
% Group Statistics (Global property)
%--------------------------------------------------------------------------
for i=1:4
    for j=(i+1):4
        dat = output.(sprintf('fcd%d%d',i,j));
        [p,tabs,stat] = anova1(dat,Group,'off');
        fprintf('FCD%d-%d, p=%.4f\n',i,j,p);
    end
end

