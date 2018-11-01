function spm_write_vols2(vref, IMGs, outdir)


% Output file name
[p,f,e] = fileparts(vref.fname);
fn_out = fullfile(outdir,[f '.nii']);

% If image is not 4D type, reshaping
if length(size(IMGs))==2
    IMGs = reshape(IMGs, [vref.dim, size(IMGs,2)]);
end

% Write images into one 4D nifti file
nscan = size(IMGs,4);
for i=1:nscan
   
    IMG = IMGs(:,:,:,i);

    hdr = vref;
    hdr.n = [i 1];
    hdr.fname=fn_out;
    
    spm_write_vol(hdr,IMG);
end