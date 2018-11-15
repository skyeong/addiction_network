fn='/Users/skyeong/toolbox/iRSFC/atlas/HarvardOxford.xls';
T = readtable(fn);

% Read ATLAS Image
fn1='/Users/skyeong/toolbox/iRSFC/atlas/HarvardOxford.nii';
vref=spm_vol(fn1);
HO=spm_read_vols(vref);

% Create bilateral PCC seed
vout = vref;
IMG = zeros(vref.dim);
IMG(HO==59 | HO==60)=1;
vout.fname='HO_PCC.nii';
spm_write_vol(vout,IMG);


% Create bilateral Amygdala seed
vout = vref;
IMG = zeros(vref.dim);
IMG(HO==109 | HO==110)=1;
vout.fname='HO_AMY.nii';
spm_write_vol(vout,IMG);



% Create bilateral NA seed
vout = vref;
IMG = zeros(vref.dim);
IMG(HO==111 | HO==112)=1;
vout.fname='HO_NA.nii';
spm_write_vol(vout,IMG);

