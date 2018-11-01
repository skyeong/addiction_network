fn_xls='/Users/skyeong/data/IGD/Demographic/subjlist_igd.xlsx';
T = readtable(fn_xls);
A = [T(T.Dx==1,:).anxiety, T(T.Dx==1,:).depression];

% kmeans
[a,b]=kmeans(A,2);

figure;
scatter(A(a==1,1),A(a==1,2),'ro'); hold on;
scatter(A(a==2,1),A(a==2,2),'bo'); 

mean(A(a==1,:))
mean(A(a==2,:))
[h,p,ci,stat]=ttest2(A(a==1,1), A(a==2,1));


pk=hist(a,1:2);pk