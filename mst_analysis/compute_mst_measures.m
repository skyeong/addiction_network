function mst = compute_mst_measures(subG)
N = size(subG.Nodes,1);
M = N-1;

% subG.Edges.Weight = ones(size(subG.Edges.Weight));

% Local property
dc = centrality(subG,'degree');
bc = centrality(subG,'betweenness')/(((N-1)*(N-2))/2);

% compute distance
disG = distances(subG,'Method','unweighted');


% Global property
leap = find(dc==1);
Lf = length(leap)/N;
kappa = mean(dc.^2.)/mean(dc);
L = sum(sum(disG))/N/(N-1);
Th = L/(2*M*max(bc));
D = max(max(disG))/M;
st = mean(subG.Edges.Weight);

% Output
mst = table();
mst.D = D;
mst.kappa = kappa;
mst.Th = Th;
mst.Lf = Lf;
% mst.dc = dc';
% mst.bc = bc';
mst.st = st;