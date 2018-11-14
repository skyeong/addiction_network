warning('off','all');


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
% Load TIV
%--------------------------------------------------------------------------
fn_tiv = fullfile(proj_path,'Results','TIV.csv');
TIV = readtable(fn_tiv);


%--------------------------------------------------------------------------
% Load Thickness
%--------------------------------------------------------------------------
fn_thickness = fullfile(proj_path,'Results','thickness.csv');
THICKNESS = readtable(fn_thickness);
names=THICKNESS.Properties.VariableNames;

for i=1:length(names)
    if strcmpi(names{i},'subjname'), continue; end
    data = THICKNESS.(names{i});
    if sum(isnan(data))>2
        continue;
    end
    [p,tabs,stat] = anova1(data,Group,'off');
    if p<0.05
        fprintf('%s, p=%.4f\n',names{i},p);
    end
end



%--------------------------------------------------------------------------
% Load Volume
%--------------------------------------------------------------------------
fn_thickness = fullfile(proj_path,'Results','volume.csv');
VOLUME = readtable(fn_thickness);
names=VOLUME.Properties.VariableNames;

for i=1:length(names)
    if strcmpi(names{i},'subjname'), continue; end
    data = VOLUME.(names{i});
    if sum(isnan(data))>2
        continue;
    end
    [p,tabs,stat] = anova1(data,Group,'off');
    if p<0.05
        fprintf('%s, p=%.4f\n',names{i},p);
    end
end
