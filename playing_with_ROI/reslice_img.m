function reslice_img(fn_ref, fn_image_to_reslice)

source = fn_image_to_reslice;
target = fn_ref;
fns = char(target,source);

flags = struct('interp',0,'mask',0,'mean',0,'which',1,'wrap',[0 0 0]');
spm_reslice(fns,flags);
