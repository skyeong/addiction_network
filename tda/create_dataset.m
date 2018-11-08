
% Directory containing Face data
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD';
fn_xls    = fullfile(proj_path,'Demographic','subjlist_igd.xlsx');
T = readtable(fn_xls);
Dx = T.Dx;
vars={'IAT','ADHD','anxiety','depression','BIS_11'};
data=[];
for i=1:length(vars)
    data = [data, T.(vars{i})];
end


% Normalize data
mu = mean(data);
sd = std(data);
ndata = (data-mu)./sd;

Y = tsne(ndata,'Algorithm','exact','Standardize',true,'Distance','euclidean' ,'Perplexity',15);
% Y = tsne(ndata,'Algorithm','exact','Standardize',true,'Distance','mahalanobis' ,'Perplexity',15);
% Y = tsne(ndata,'Algorithm','exact','Standardize',true,'Distance','correlation' ,'Perplexity',15);
% Y = pca(ndata', 'NumComponents',2);
figure; plot(Y(:,1), Y(:,2),'o')

f1 = Y(:,1);
f2 = Y(:,2);
d = L2_distance(ndata',ndata');
save('tda.mat','f1','f2','d')

for i=1:length(vars)
    dlmwrite([vars{i} '.txt'],T.(vars{i}));
end


subg = zeros(length(f1),1);
subg(T.Group==1)=1;
dlmwrite('subg1.txt',subg);


subg = zeros(length(f1),1);
subg(T.Group==2)=1;
dlmwrite('subg2.txt',subg);