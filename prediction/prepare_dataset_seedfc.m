warning('off','all');
addpath(genpath('/Users/skyeong/toolbox/iRSFC'));


seedname='OFC_R';
% seedname='NAccR_3mm';
% seedname='Amyg_6mm';
% seedname='NAcc_3mm';

% Load dataset
%--------------------------------------------------------------------------
fmridir = 'rest_24HM';



% Directory containing Face data
%--------------------------------------------------------------------------
proj_path = '/Users/skyeong/data/IGD';
fn_xls    = fullfile(proj_path,'Demographic','subjlist_igd.xlsx');
T = readtable(fn_xls);
Group = T.Dx;
subjlist = T.subjname;
nsubj = length(subjlist);


%  Obtaining Brain Mask From the first Subject IMG Header Info
%--------------------------------------------------------------------------
data_path = fullfile(proj_path,'Results','staticFC_zmaps',seedname);
fn_ref = fullfile(data_path,fmridir,sprintf('zscore_%s_%s.nii',seedname,subjlist{1}));
vref = spm_vol(fn_ref); vref = vref(1);
[idbrainmask,idgm,idwm,idcsf] = fmri_load_maskindex(vref);
nvox=length(idbrainmask);

all_fc = zeros(nvox,nsubj);
for c=1:nsubj
    subjname = subjlist{c};
    zscorefile = sprintf('zscore_%s_%s.nii',seedname,subjname);
    fn = fullfile(proj_path,'Results','staticFC_zmaps',seedname,fmridir,zscorefile);
    vo = spm_vol(fn);
    IMG = spm_read_vols(vo);
    all_fc(:,c)=IMG(idbrainmask);
end


% ------------ INPUTS -------------------
out_path = fullfile(proj_path,'Results','cpm_mask');
% threshold for feature selection
thresh = 0.001;

% scales={'RSES','Autonomy','Competence','Relatedness','Anxiety','Depression'};
% scales={'RSES','SWLS'};
scales={'IAT','ADHD','anxiety','depression','RSES','BIS_11','BIS_11_att','BIS_11_motor','BIS_11_nonplan'};

grpid=0;
for i=1:length(scales)
    behname = scales{i};
    
    % % Load symptom data
    all_behav   = T.(behname);
    
    % ---------------------------------------
    all_mats=all_fc(:,Group==grpid);
    all_behav=all_behav(Group==grpid);
    
    % correlate all edges with behavior
    [r_mat,p_mat] = corr(all_mats',all_behav);
    
    % set threshold and define masks
    idx_pos_edges = r_mat > 0 & p_mat < thresh;
    idx_neg_edges = r_mat < 0 & p_mat < thresh;
    
    % cluster_thresholding
    idx_edges='';
    outdir = fullfile(out_path,behname,seedname,fmridir,'CON','positive');
    idx_edges.pos = cluster_thresholding(vo,idbrainmask,idx_pos_edges,outdir);
    outdir = fullfile(out_path,behname,seedname,fmridir,'CON','negative');
    idx_edges.neg = cluster_thresholding(vo,idbrainmask,idx_neg_edges,outdir);
    
    if sum(idx_edges.pos)+sum(idx_edges.neg)>0
        fprintf('CON Group: %s\n',behname)
        behavioralprediction_seedfc(idx_edges,all_mats,all_behav);
    end
end
fprintf('\n')

grpid=1;
for i=1:length(scales)
    behname = scales{i};
    
    % Load symptom data
    all_behav   = T.(behname);
    
    % ---------------------------------------
    all_mats=all_fc(:,Group==grpid);
    all_behav=all_behav(Group==grpid);
    
    % correlate all edges with behavior
    [r_mat,p_mat] = corr(all_mats',all_behav);
    
    % set threshold and define masks
    idx_pos_edges = r_mat > 0 & p_mat < thresh;
    idx_neg_edges = r_mat < 0 & p_mat < thresh;
    
    % cluster_thresholding
    idx_edges='';
    outdir = fullfile(out_path,behname,seedname,fmridir,'IGD','positive');
    idx_edges.pos = cluster_thresholding(vo,idbrainmask,idx_pos_edges,outdir);
    outdir = fullfile(out_path,behname,seedname,fmridir,'IGD','negative');
    idx_edges.neg = cluster_thresholding(vo,idbrainmask,idx_neg_edges,outdir);
    
    if sum(idx_edges.pos)+sum(idx_edges.neg)>0
        fprintf('IGD Group: %s\n',behname)
        behavioralprediction_seedfc(idx_edges,all_mats,all_behav);
    end
end