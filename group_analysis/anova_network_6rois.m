warning('off','all');

roinames={'OFC_L','OFC_R','MCC_L','MCC_R','HO_vStr_L','HO_vStr_R'};

%--------------------------------------------------------------------------
% Directory containing preprocessed IGD dataset
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD';
fn_xls    = fullfile(proj_path,'Demographic','subjlist_igd.xlsx');
T = readtable(fn_xls);
Group = T.Group;
subjlist = T.subjname;
nsubj = length(subjlist);



%--------------------------------------------------------------------------
% Load functional connectivity
%--------------------------------------------------------------------------
nrois=6;
FC = zeros(nsubj,nrois*(nrois-1)/2);
mat_dir = fullfile(proj_path,'Results','staticFC_Aij','roi_n6','rest1');
for c=1:nsubj
    subjname = subjlist{c};
    fn_mat = fullfile(mat_dir,['network_' subjname '.mat']);
    load(fn_mat);
    
    cnt=1;
    for i=1:nrois
        for j=(i+1):nrois
            FC(c,cnt)=Z(i,j);
            cnt = cnt+1;
        end
    end
    
end


%--------------------------------------------------------------------------
% Group Statistics (for each edge)
%--------------------------------------------------------------------------
cnt=1;
pvals=[];
for i=1:nrois
    for j=(i+1):nrois
        dat = FC(:,cnt);
        [p,tabs,stat] = anova1(dat,Group,'off');
        if p<0.005
            fprintf('%s-%s, p=%.4f,**\n',roinames{i},roinames{j},p);
        elseif p<0.5
            fprintf('%s-%s, p=%.4f,*\n',roinames{i},roinames{j},p);
        end
        pvals=[pvals; p];
        cnt = cnt+1;
    end
    %     [a,b,c,adj_p]=fdr_bh(pvals);
    %     if pvals<0.05
    %         fprintf('%s-%03d, p=%.4f\n',vars{i},j,adj_p);
    %     end
    %     fprintf('\n')
end



