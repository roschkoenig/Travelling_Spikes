function ts_dcm_specify(sub)

% Housekeeping
%--------------------------------------------------------------------------
disp(['Loading files for ' sub]);
D   = ts_housekeeping;
fs  = filesep;
Fdata   = [D.Fdata fs sub];
Fmeeg   = [D.Fanalysis fs 'MEEG'];

spm('defaults', 'eeg')

% Find data files and loop through
%--------------------------------------------------------------------------
meegfiles = cellstr(spm_select('FPList', Fmeeg, ['^MEEG_' sub '_.*\.mat']));

for m = 1:length(meegfiles)
clear DCM   

DCM.xY.Dfile    = meegfiles{m};
MEEG            = spm_eeg_load(DCM.xY.Dfile);
conds           = condlist(MEEG);
dists           = str2double(chanlabels(MEEG));

[loc(1).dist, loc(1).id]	= min(dists);           loc(1).name = 'wm';
[loc(2).dist, loc(2).id]	= min(abs(dists));      loc(2).name = 'cr';
[loc(3).dist, loc(3).id]	= max(dists);           loc(3).name = 'gm';

for l = 1:length(loc)    
    
% Set up folders, set up shop
%--------------------------------------------------------------------------

try, mkdir([D.Fanalysis fs 'DCM']); end

dotpos = find(meegfiles{m} == '.');
seppos = find(meegfiles{m} == '_');
el              = meegfiles{m}(seppos(end)+1:dotpos(end)-1);
DCM.name        = [D.Fanalysis fs 'DCM' fs sub '_' el '_' loc(l).name];

% Parameters and options used for setting up model
%--------------------------------------------------------------------------
DCM.options.trials      = 1:length(conds);
DCM.options.analysis    = 'ERP';
DCM.options.model       = 'ERP';
DCM.options.spatial     = 'LFP';
DCM.options.Tdcm        = [-150 350];
DCM.options.onset       = -50;
DCM.options.dur         = 20;
DCM.options.Nmodes      = 3;
DCM.options.h           = 1;
DCM.options.han         = 1;
DCM.options.D           = 1;

% Data and spatial model
%--------------------------------------------------------------------------
DCM.Sname               = chanlabels(MEEG)';
Nareas                  = length(DCM.Sname); 

% Specify connectivity model
%--------------------------------------------------------------------------
DCM.A{1} = zeros(Nareas);   % Forward
DCM.A{2} = zeros(Nareas);   % Backward
DCM.A{3} = zeros(Nareas);   % Lateral

for a = 1:Nareas-1
	DCM.A{1}(a+1, a) = 1;
    DCM.A{2}(a, a+1) = 1;
end

for i = 1:length(conds)-1
    DCM.B{i} = zeros(Nareas) + DCM.A{1} + DCM.A{2} + DCM.A{3};
    for b = 1:length(DCM.B{i})
        DCM.B{i}(b,b) = 1;
    end
end

DCM.C = zeros(Nareas,1);
DCM.C(loc(l).id) = 1;
disp(['Giving the model input at ' loc(l).name])

% Between trial effects
%--------------------------------------------------------------------------
for i = 1:length(conds)-1
    DCM.xU.X(:,i)     = zeros(length(conds),1);
    DCM.xU.X(i+1,i)   = 1;
    DCM.xU.name{i}    = ['Transition to ' num2str(i+1)];
end

DCM = spm_dcm_erp(DCM);

end
end
    