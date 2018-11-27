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
subjlist = T.subjname;
nsubj = length(subjlist);

covars = [T.age,  T.KWAIS];
scales = {'RSES','IAT','ADHD','anxiety','depression','BIS_11'};


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
    fn = fullfile(proj_path,'Results','staticFC_Aij',atlasName,'rest_12HM',matfile);
    load(fn);
    
    % Take positive edges
    R(R<0) = 0;
    R(R>0) = 1./R(R>0);  % inverse
    % Get network backbone
    corrD = graph(R,'upper');
    subG  = minspantree(corrD);
    subG.Edges.Weight = 1./subG.Edges.Weight; % invert to have original weights
    mst = compute_mst_measures(subG);
    
    % Controllability
    A = full(subG.adjacency('weight')); N = length(A);
    [Nd, dn, Nconfig] = ExactControllability(A,'plotting',0);
    
    % Degree Strength and betweenness centrality
    dc = strengths_und(A);
    bc = betweenness_wei(A);
    
    mst.subjname = {subjname};
    mst.Group = Group(c);
    mst.Nd = Nd;
    mst.dc = dc(:)';
    mst.bc = bc(:)';
    
    %     mst.dn = dn(:)';
    output = [output; mst];
end
writetable(output,'~/Desktop/mst.csv');


%--------------------------------------------------------------------------
% Group Statistics (Global property)
%--------------------------------------------------------------------------
vars={'D','kappa','Th','Lf','st'};
for i=1:length(vars)
    dat = output.(vars{i});
    [p,tabs,stat] = anova1(dat,Group,'off');
    %      [ T, p, FANCOVAN, pANCOVAN, stats ] = mancovan(dat, Group, covars,{ 'SVD' 'group-group' } );
    
    fprintf('%s, p=%.4f\n',vars{i},p(1));
end



%--------------------------------------------------------------------------
% Correlation between Scales and Nodal Properties
%--------------------------------------------------------------------------
vars={'dc','bc'};
for i=1:length(vars)
    dat1 = output.(vars{i});  % nodal property
    
    for j=1:length(scales)
        dat2 = T.(scales{j});  % scales
        
        pvals0=[]; rr0=[];
        pvals1=[]; rr1=[];
        pvals2=[]; rr2=[];
        
        for k=1:nrois
            [r0,p0]=partialcorr(dat1(Group==0,k), dat2(Group==0), covars(Group==0));
            [r1,p1]=partialcorr(dat1(Group==1,k), dat2(Group==1), covars(Group==1));
            [r2,p2]=partialcorr(dat1(Group==2,k), dat2(Group==2), covars(Group==2));
            pvals0=[pvals0; p0]; rr0=[rr0; r0];
            pvals1=[pvals1; p1]; rr1=[rr1; r1];
            pvals2=[pvals2; p2]; rr2=[rr2; r2];
        end
        
        [a,b,c,adj_p0]=fdr_bh(pvals0);
        for k=1:nrois
            if adj_p0(k)<0.05
                fprintf('G0,%s-%03d & %s, rho=%.2f, p=%.4f,**\n',vars{i},k,scales{j},rr0(k),adj_p0(k));
                figure; plot(dat1(Group==0,k), dat2(Group==0),'o'); title('G0');
            end
        end
        
        [a,b,c,adj_p1]=fdr_bh(pvals1);
        for k=1:nrois
            if adj_p1(k)<0.05
                fprintf('G1,%s-%03d & %s, rho=%.2f, p=%.4f,**\n',vars{i},k,scales{j},rr1(k),adj_p1(k));
                figure; plot(dat1(Group==1,k), dat2(Group==1),'o'); title('G1');
            end
        end
        [a,b,c,adj_p2]=fdr_bh(pvals2);
        for k=1:nrois
            if adj_p2(k)<0.05
                fprintf('G2,%s-%03d & %s, rho=%.2f, p=%.4f,**\n',vars{i},k,scales{j},rr2(k), adj_p2(k));
                figure; plot(dat1(Group==2,k), dat2(Group==2),'o'); title('G2');
            end
        end
    end
    
    
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


