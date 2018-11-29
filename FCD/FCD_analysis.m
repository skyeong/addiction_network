warning('off','all');
addpath(genpath('/Users/skyeong/matlabscripts/toolbox/controllability'));
addpath(genpath('/Users/skyeong/connectome/bct'));
addpath(genpath('/Users/skyeong/matlabscripts/toolbox/mancovan_496/'));
addpath('/Users/skyeong/projects/addiction_network/fdr_bh');


% Directory containing Face data
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD';
fn_xls    = fullfile(proj_path,'Demographic','subjlist_igd.xlsx');
T = readtable(fn_xls);
Group = T.Group;
Dx = T.Dx;
subjlist = T.subjname;
nsubj = length(subjlist);

covars = [T.age,  T.KWAIS];
scales = {'RSES','IAT','ADHD','anxiety','depression','BIS_11'};


% Atlas Name
%--------------------------------------------------------------------------
% atlasName = 'AAL'; nrois=90;
atlasName = 'shen_268'; nrois=268;
% atlasName = 'HarvardOxford'; nrois=112;

idremove=[100:119, 129:133, 236:256 265:268];
% nrois = nrois-length(idremove);

fn = '/Users/skyeong/toolbox/iRSFC/atlas/shen_268_parcellation_networklabels.csv';
T1 = readtable(fn);
nodeid=T1.Node;
networkid=T1.Network;

FCD = zeros(8,8,subj);
output = table();
for c=1:nsubj
    subjname = subjlist{c};
    matfile = sprintf('network_%s.mat',subjname);
    fn = fullfile(proj_path,'Results','staticFC_Aij',atlasName,'rest_12HM',matfile);
    load(fn);
    R(eye(nrois)==1)=nan;
    
    for i=1:8
        nodes_i = find(networkid==i);
        nodes_i = setdiff(nodes_i,idremove);
        
        for j=i:8
            nodes_j = find(networkid==j);
            nodes_j = setdiff(nodes_j,idremove);
            
            R1 = R(nodes_i,nodes_j);
            FCD(i,j,c) = nanmean(R1(:));
        end
    end
end


% Twosample t-test
for i=1:8
    for j=i:8
        [h,p,ci,stat]=ttest2(FCD(i,j,find(Dx==0)), FCD(i,j,find(Dx==1)));
        if p<0.05
            fprintf('fcd%d-%d, p=%.4f\n',i,j,p);
        end
    end
end