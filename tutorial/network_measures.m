proj_path = '/Users/skyeong/data/IGD/Results/roi_n90/rest1';
fns = dir(fullfile(proj_path,'*.mat'));

fn1 = fns(1).name;

% load mat file
load(fullfile(proj_path,fn1));
R(R<0.6)=0;
A = R;
A(A>0)=1;
k = sum(A)';

figure; hist(deg)
C=diag(A*A*A)./(k.*(k-1));
C1 = clustering_coef_bu(A);
bc = betweenness_bin(A);