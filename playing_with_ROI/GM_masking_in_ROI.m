proj_path='/Users/skyeong/data/IGD';
roinames={'MCC_L','MCC_R','OFC_L','OFC_R','HO_vStr_L','HO_vStr_R'};


% Reslice images
fn_ref = fullfile(spm('dir'),'tpm','TPM.nii,1');
for i=1:length(roinames)
    fn_source = fullfile(proj_path,'ROI',[roinames{i},'.nii']);
    reslice_img(fn_ref,fn_source);
end


% Load Tissue Probability Map (TPM)
fn_tpm = fullfile(spm('dir'),'tpm','TPM.nii');
vo_tpm = spm_vol(fn_tpm);
TPM = spm_read_vols(vo_tpm);
GM = TPM(:,:,:,1); idxGM = find(GM>0.5);
WM = TPM(:,:,:,2); idxWM = find(WM<0.5);
idx = intersect(idxGM,idxWM);


% Threshold to identify voxels in GM  not in WM
for i=1:length(roinames)
    fn_source = fullfile(proj_path,'ROI',['r' roinames{i},'.nii']);
    vo = spm_vol(fn_source);
    I = spm_read_vols(vo);
    idroi = find(I>0);
    
    idmask = intersect(idx,idroi);
    Iout = zeros(vo.dim);
    Iout(idmask)=1;
    fn_out = fullfile(proj_path,'ROI',['r' roinames{i},'2.nii']);
    vout = vo;
    vout.fname=fn_out;
    spm_write_vol(vout,Iout);
end


