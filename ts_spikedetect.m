if ~exist('D'),   D = ts_housekeeping;    end
Fdata = D.Fdata;

edflist = cellstr(spm_select('FPlist', Fdata, '^*.edf$'));
clear E
for e = 1:length(edflist)
    hdr = ft_read_header(edflist{e});
    dat = ft_read_data(edflist{e});
    dat = ft_preproc_bandpassfilter(dat, hdr.Fs, [1 100]);
    dat = dat - mean(dat,2);

% This still needs sorting out proper
    chid = 1:11;
    shdat = dat(chid,:)';
    clear spkt spkc
    try [spkt spkc]  = DetectSpike_GC(shdat, hdr.Fs, hdr.nSamples / hdr.Fs / 60); end
    if exist('spkt')
        E(e).spkt = spkt;
        E(e).spkc = spkc;
    end

end

% Find spikes that are close together
%--------------------------------------------------------------------------
win = 0.5 * hdr.Fs;
k   = 0;

for e = 1:length(E)
for s = 1:length(E(e).spkt)
    ul  = E(e).spkt(s) + win;
    ll  = E(e).spkt(s) - win;
    
    grp = find(E(e).spkt > ll & E(e).spkt < ul);
    if length(grp) >= 2
        k = k + 1; 
        Sp(k).t = E(e).spkt(s);
        Sp(k).c = E(e).spkc(s);
        Sp(k).f = e;
    end
end 
end

[std stg] = sort([Sp.t]);   Sp = Sp(stg);
[std stg] = sort([Sp.f]);   Sp = Sp(stg);


%% Find clusters
%--------------------------------------------------------------------------
first   = 1;
k       = 1;
clear gS

for s = 1:length(Sp) - 1
    dt = Sp(s+1).t - Sp(s).t; 
    if dt > win
        if length(unique([Sp(first:s).c])) > 1
            gS(k).t = [Sp(first:s).t];
            gS(k).c = [Sp(first:s).c];
            gS(k).f = edflist{Sp(first).f};
            k       = k + 1;
        end
        first = s+1;
    end
end

%% Plot examples

plstrt = -3 * hdr.Fs;
plstop  = 7 * hdr.Fs;

for g = 1:length(gS)
    thischid = chid(unique(gS(g).c));
    

end
    
    