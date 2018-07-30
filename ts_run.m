D       = ts_housekeeping;
subs    = cellstr(spm_select('List', D.Fdata, 'dir', '^.*'));

%% Run preprocessing
%--------------------------------------------------------------------------
for s = 1:length(subs)
    sub = subs{s}
    ts_preproc(sub);
end

%% Detect spikes
%--------------------------------------------------------------------------
for s = 1:length(subs)
    sub = subs{s}
    ts_spikedetect(sub);
end

%% Identify group spikes
%--------------------------------------------------------------------------
for s = 1:length(subs)
    sub = subs{s}
    ts_groupspikes(sub);
end

%% Save groups of spikes into separate files
%--------------------------------------------------------------------------
for s = 1:length(subs) 
    sub = subs{s}
    ts_filemaker(sub);
end

%% Calculate delays
%--------------------------------------------------------------------------
for s = 1:length(subs) 
    sub = subs{s}
    ts_crosscorr(sub);
end

%% Match channel labels with MRI descriptors
%--------------------------------------------------------------------------
for s = 1:length(subs)
    sub = subs{s}
    ts_chanmatch(sub);
end

%% Calculate delay statistics
%--------------------------------------------------------------------------
for s = 1:length(subs)
    sub = subs{s}
    ts_delaystats(sub);
end

% Plot summary statistics
ts_summarystats

%% Generate summary datasets for DCM analysis
%--------------------------------------------------------------------------
for s = 1:length(subs)
    sub = subs{s}
    ts_meegcluster(sub);
end

%% Run DCM analysis
%--------------------------------------------------------------------------
for s = 1:length(subs)
    sub = subs{s}
    ts_dcm_specify(sub);
end
