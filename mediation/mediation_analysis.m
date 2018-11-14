
%--------------------------------------------------------------------------
% IAT -> Depression (mediator: kappa)
%--------------------------------------------------------------------------
Group = T.Group;
X = T.IAT;
Y = T.BIS_11;
M = output.kappa;
[paths2, stats2] = mediation(X(Group>0), Y(Group>0), M(Group>0), 'verbose', 'boot', 'bootsamples', 10000);


[paths0, stats0] = mediation(X(Group==0), Y(Group==0), M(Group==0),  'verbose', 'boot', 'bootsamples', 10000);
[paths1, stats1] = mediation(X(Group==1), Y(Group==1), M(Group==1),  'verbose', 'boot', 'bootsamples', 10000);
[paths2, stats2] = mediation(X(Group==2), Y(Group==2), M(Group==2) ,'verbose', 'boot', 'bootsamples', 10000);

[paths2, stats2] = mediation(X, Y, M, 'plots', 'verbose', 'boot', 'bootsamples', 10000);

