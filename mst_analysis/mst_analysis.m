warning('off','all');
addpath(genpath('/Users/skyeong/matlabscripts/toolbox/controllability'));
addpath('/Users/skyeong/projects/addiction_network/fdr_bh');


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
% atlasName = 'HarvardOxford'; nrois=112;

fn_atlas = fullfile(proj_path,'Atlas',[atlasName '.nii']);
vo_atlas = spm_vol(fn_atlas);
ATLAS = spm_read_vols(vo_atlas);


output = table();
for c=1:nsubj
    subjname = subjlist{c};
    matfile = sprintf('network_%s.mat',subjname);
    fn = fullfile(proj_path,'Results','staticFC_Aij',atlasName,'rest1',matfile);
    load(fn);
    
    % Get network backbone
    corrD = graph(1-R,'upper');
    subG  = minspantree(corrD);
    subG.Edges.Weight = 1-subG.Edges.Weight;
    mst = compute_mst_measures(subG);
    
    % Controllability
    A = full(subG.adjacency); N = length(A);
    [Nd, dn, Nconfig] = ExactControllability(A,'plotting',0);
    
    mst.subjname = {subjname};
    mst.Group = Group(c);
    mst.Nd = Nd;
%     mst.dn = dn(:)';
    output = [output; mst];
end
writetable(output,'~/Desktop/mst.csv');


%--------------------------------------------------------------------------
% Group Statistics (Global property)
%--------------------------------------------------------------------------
vars={'D','kappa','Th','Lf','st','Nd'};
for i=1:length(vars)
    dat = output.(vars{i});
    [p,tabs,stat] = anova1(dat,Group,'off');
    fprintf('%s, p=%.4f\n',vars{i},p);
end

return

%--------------------------------------------------------------------------
% Group Statistics (Nodal property)
%--------------------------------------------------------------------------
vars={'dc','bc'};
for i=1:length(vars)
    dat = output.(vars{i});
    pvals=[];
    for j=1:nrois
        [p,tabs,stat] = anova1(dat(:,j),Group,'off');
        if p<0.005
            fprintf('%s-%03d, p=%.4f,**\n',vars{i},j,p);
        elseif p<0.05
            fprintf('%s-%03d, p=%.4f,*\n',vars{i},j,p);
        end
        pvals=[pvals; p];
    end
    %     [a,b,c,adj_p]=fdr_bh(pvals);
    %     if pvals<0.05
    %         fprintf('%s-%03d, p=%.4f\n',vars{i},j,adj_p);
    %     end
    %     fprintf('\n')
end




%--------------------------------------------------------------------------
% Permutation Testing (Nodal property)
%--------------------------------------------------------------------------
nperm=5000;
vars={'dc','bc'};
for i=1:length(vars)
    dat = output.(vars{i});
    fvals=zeros(nperm,nrois);
    for j=1:nperm
        idx = randperm(nsubj);
        for k=1:nrois
            [p,tabs,stat] = anova1(dat(:,k),Group(idx),'off');
            fvals(j,k)=tabs{2,5};
        end
    end
    
    for k=1:nrois
        [p,tabs,stat] = anova1(dat(:,k),Group,'off');
        f=tabs{2,5};
        alpha = sum(fvals(:,k)>f)/nperm;
        if alpha<0.005
            fprintf('%s-%03d, p=%.4f,**\n',vars{i},k,alpha);
        elseif alpha<0.05
            fprintf('%s-%03d, p=%.4f,*\n',vars{i},k,alpha);
        end
    end
    fprintf('\n');
end


