% ts_crosscorr

sub         = 'SaKh';
fs          = filesep;

try
    D   = ts_housekeeping;
catch
    dfile = cellstr(spm_select(1, 'any', 'Please select the ts_housekeeping.m file'));
    [dpath dfile]   = fileparts(dfile{1});
    addpath(dpath);
    D   = ts_housekeeping;
end

Fdata = [D.Fdata fs sub];

%%
load([Fdata fs 'SPK.mat']);

% Go through all spike groups
for e = 1
for g = 1
    grp = SPK(e).gS(g);
    f   = ts_fixpath(Fdata, grp.f);
    h   = ft_read_header(f);
    
    % Load 1s time window around spike
    %----------------------------------------------------------------------
    pre     = min(grp.t) - 0.3 * h.Fs;
    pst     = min(grp.t) + 0.7 * h.Fs;
    chid    = [SPK(e).shk.ind];
    d       = ft_read_data(f, 'begsample', pre, 'endsample', pst);
    d       = ft_preproc_bandpassfilter(d, h.Fs, [1 100]);
    d       = ft_preproc_bandstopfilter(d, h.Fs, [49 51]);
%     d       = ts_rereference(d,
    d       = d(chid,:);
    
    % calculate cross correlations with earliest spike 
    %----------------------------------------------------------------------
    [val ons]   = min(grp.t);    
    xcori       = find([1:size(d,1)] ~= ons);
    clear x lags
    for k = 1:size(d,1)-1
        i = xcori(k);
        [c(k,:) lags(k,:)] = xcorr(d(ons,:), d(i,:));
    end
    
end
end