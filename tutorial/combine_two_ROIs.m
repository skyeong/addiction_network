f1 = 'NAccL_3mm.nii';
f2 = 'NAccR_3mm.nii';

v1  =spm_vol(f1);
v2 = spm_vol(f2);

I1 = spm_read_vols(v1);
I2 = spm_read_vols(v2);

I = I1+I2;
vout=v1;
vout.fname='NAcc_3mm.nii';
spm_write_vol(vout,I);