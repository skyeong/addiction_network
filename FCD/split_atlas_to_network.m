vo=spm_vol('/shen_268.nii');
I = spm_read_vols(vo);

% split each node from shen_268 parcellation
for i=1:268
    I2=zeros(size(I));
    idx = find(I==i);
    I2(idx)=1;
    vout=vo;
    vout.fname=sprintf('shen_%03d.nii',i);
    spm_write_vol(vout,I2);
end

% create modular architecture of shen_268
for i=1:8
    I2=zeros(size(I));
    id_nodes = find(ci==i);
    
    % collect nodes within each network
    idx=[];
    for j=1:length(id_nodes)
        idx = [idx; find(I==id_nodes(j))];
    end
    I2(idx)=1;
    vout=vo;
    vout.fname=sprintf('shen_N%03d.nii',i);
    spm_write_vol(vout,I2);
end