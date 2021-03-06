function ts_spikedetect(sub)

% TS Spike Detection
%==========================================================================
% This script will take EDF files, adn detect group of spikes that occur in
% short temporal windows across multiple channels on the same SEEG
% electrode.
% Folder strucutre is defined in ts_housekeeping.m - where you should point
% towards a scripts folder (where all the scripts are saved), and a data
% folder (where all the patient data are saved). In the data folder, each
% subject should have their own folder named with the subject name
% Patient details are defined in ts_patients - including electrode labels
%--------------------------------------------------------------------------
try
    D   = ts_housekeeping;
catch
    dfile = cellstr(spm_select(1, 'any', 'Please select the ts_housekeeping.m file'));
    [dpath dfile]   = fileparts(dfile{1});
    addpath(dpath);
    D   = ts_housekeeping;
end

P           = ts_patients(sub);
eoi         = P.eoi;
fs          = filesep;

Fdata       = [D.Fdata fs sub];
edflist     = cellstr(spm_select('FPlist', Fdata, '^p.*\.edf$'));

clear SPK E

% Loop through electrodes (i.e. shanks) of interest
%==========================================================================
clear Sp
disp('Loading datasets');

% Load and preprocess relevant data
%----------------------------------------------------------------------
for e = 1:length(edflist)
    hdr = ft_read_header(edflist{e});
    dat = ft_read_data(edflist{e});

    clear spkt spkc
    try [spkt spkc spft]  = DetectSpike_GC(dat', hdr.Fs); end  % 5, hdr.nSamples / hdr.Fs / 60, ...     % data, Fs, blocksize
                                           % 70, 4, [7; 7; 100; 10; 10]); end
    if exist('spkt')
        E(e).spkt = spkt;
        E(e).spkc = spkc;
        E(e).spft = spft;
    end
end

if ~exist('E'), E = [];       end
save([Fdata fs sub '_raw_spikes'], 'E');
