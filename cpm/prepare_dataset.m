warning('off','all');



% Directory containing Face data
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD';
fn_xls    = fullfile(proj_path,'Demographic','subjlist_igd.xlsx');
T = readtable(fn_xls);
Group = T.Group;
Dx = T.Dx;
subjlist = T.subjname;
nsubj = length(subjlist);
% Atlas Name
%--------------------------------------------------------------------------
atlasName = 'AAL'; nrois=90;
% atlasName = 'shen_268'; nrois=268;


% Load dataset
%--------------------------------------------------------------------------
rest_1_mats = zeros(nrois,nrois,nsubj);
for c=1:nsubj
    subjname = subjlist{c};
    matfile = sprintf('network_%s.mat',subjname);
    fn = fullfile(proj_path,'Results','staticFC_Aij',atlasName,'rest_12HM',matfile);
    load(fn);
    rest_1_mats(:,:,c)=R;
end


% ------------ INPUTS -------------------
all_mats  = rest_1_mats(:,:,Dx==1);
% all_mats  = rest_1_mats;

% Load symptom data
all_behav   = T.IAT(Dx==1);
% all_behav   = T.anxiety(Dx==1);
% all_behav   = T.depression(Dx==1);
% all_behav   = T.RSES(Dx==0);
% all_behav   = T.ADHD(Dx==1);
% all_behav   = T.BIS_11(Dx==1);

all_covars  = [T.age, T.eduyear, T.KWAIS];
all_covars = all_covars(Dx==1,:);

% threshold for feature selection
thresh = 0.01;

% ---------------------------------------
behavioralprediction(all_mats,all_behav, thresh);
% behavioralprediction_partial(all_mats,all_behav,all_covars, thresh)