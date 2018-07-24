function ts_groupspikes(sub)
%--------------------------------------------------------------------------
% This function will take a list of all detected spikes (saved as
% 'raw_spikes' in the subject specific folder) and identify groups of
% spikes that occur with short latencies along the same electrode. All of
% these will be saved in a single file 'spike_groups' in the subject folder

% Load raw spike file
%--------------------------------------------------------------------------
disp(['Loading files for ' sub]);
D   = ts_housekeeping;
fs  = filesep;
Fdata   = [D.Fdata fs sub];

load([D.Fdata fs sub fs sub '_raw_spikes.mat']);
edflist     = cellstr(spm_select('FPlist', Fdata, '^p.*\.edf$'));
if length(edflist) == length(E),    disp('Yay! Found all the right files :)'); end

hdr = ft_read_header(edflist{1}); 
shk = ts_shankdetect(hdr.label);
sid = unique([shk.ind]);
snm = unique({shk.name});

% Find spikes that are close together in time and on the same electrode
%--------------------------------------------------------------------------
disp(['Finding spikes']);
win = 0.1 * hdr.Fs;
k   = 0;

clear Sp gS
k = 0;

for e = 1:length(E)                 % Goes through all files
for h = 1:length(sid)               % Goes through each individual electrode
    
    % Generate temporary data structure
    %----------------------------------------------------------------------
    tE  = E(e);
    tid = find([shk(E(e).spkc).ind] == h);
    
    % Pull out the spikes for this electrode and file
    %----------------------------------------------------------------------
    spkt = E(e).spkt(tid);
    spkc = E(e).spkc(tid);
    spft = E(e).spft(tid);
    
    [std stg] = sort(spkt);
    spkt    = spkt(stg);
    spkc    = spkc(stg);
    spft    = spft(stg);
    
    gid = [];
    for s = 1:(length(spkt)-1)
        dt = spkt(s+1) - spkt(s);
        if dt < win
            gid = [gid; s];
        else 
            if length(unique(spkc(gid))) == length(gid) && length(gid) > 2
                k = k + 1;
                [fpath fname] = fileparts(edflist{e});
                gS(k).t     = spkt(gid);
                gS(k).c     = spkc(gid);
                gS(k).f     = fname;
                gS(k).e     = snm{h};
            end
            gid = [];
        end
        
    end
end
end

save([Fdata fs sub '_spike_groups.mat'], 'gS');
