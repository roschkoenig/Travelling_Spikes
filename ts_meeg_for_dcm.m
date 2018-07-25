fs    	= filesep;
D       = ts_housekeeping;
sub     = 'JoDa'
Fdata   = [D.Fdata fs sub];

% Load channel position files
%--------------------------------------------------------------------------
load([Fdata fs sub '_chanlab.mat']);

% Modelling electrode E, spike 3
E = 'E';
s = 3;

ci = find(strcmp({Epos.el}, E));
Einfo = Epos(ci);

D       = spm_eeg_load([Fdata fs 'MEEG_' sub '_' E '.mat']);
roi     = ts_goodchan(D);
labels  = chanlabels(D);

clear ftdata
ftdata.trial{1} = D(roi, :, s);
ftdata.time{1}  = time(D);
%%
for l = 1:length(roi)
    ftdata.label{l} = num2str(Einfo.dists(roi(l)));
end

clear D
D = spm_eeg_ft2spm(ftdata, [Fdata fs 'MEEG']);

for d = 1:size(D,1); type{d} = 'LFP'; end
D = chantype(D, 1:length(type), type);
save(D);
