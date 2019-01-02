function idxout=cluster_thresholding(vol,idbrainmask,idroi,outdir)
idroi_index = find(idroi);
idloc=idbrainmask(idroi);
[vx, vy, vz] = ind2sub(vol.dim, idloc);
ilab=spm_clusters([vx vy vz]')';

idxout = [];
for i=1:max(ilab)
    idx = find(ilab==i);
    idfoci = idloc(idx);
    
    % Remove small size clusters
    if length(idx)<100, continue; end
    idxout=[idxout; idroi_index(idx(:))];
    
    newIMG = zeros(vol.dim);
    newIMG(idfoci) = 1;
    
    mkdir(outdir);
    vo = vol;
    %     fn=sprintf('subj%02d_ROI%03d.nii',subjid,i);
    fn = sprintf('ROI%03d.nii',i);
    %fprintf('writing %s (vx = %d) ...\n',fn,length(idfoci));
    vo.fname=fullfile(outdir,fn);
    vo.dt=[4 0];
    spm_write_vol(vo,newIMG);
end
