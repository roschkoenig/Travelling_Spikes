if ~exist('D'),   D = ts_housekeeping;    end
fs    = filesep;
Fdata = D.Fdata;
%%
edflist = cellstr(spm_select('FPlist', Fdata, '^*.EDF$'));
=======
D           = ts_housekeeping;   
eoi         = {'A', 'B', 'C', 'D', 'E', 'F', 'B''', 'C''', 'F''' };
fs          = filesep;
Fdata       = D.Fdata;
edflist     = cellstr(spm_select('FPlist', Fdata, '^*.edf$'));
doplot      = 0;
clear E

% Loop through electrodes (i.e. shanks) of interest
%==========================================================================
for ei = 1:length(eoi)
    clear Sp
    disp(['Currently on electrode ' num2str(ei) ' of ' num2str(length(eoi)) ': ' eoi{ei}]);
    disp('Loading datasets');
    
    % Load and preprocess relevant data
    %----------------------------------------------------------------------
    for e = 1:length(edflist)
        hdr = ft_read_header(edflist{e});
        dat = ft_read_data(edflist{e});
        dat = ft_preproc_bandpassfilter(dat, hdr.Fs, [1 100]);
        dat = dat - mean(dat,2);

        % Reduce to the channel set of interest
        %------------------------------------------------------------------
        El.lbl  = hdr.label;
        El.eoi  = eoi{ei};
        shk     = ts_shankfind(El);
        
        chid    = [shk.ind]; 
        shdat   = dat(chid,:)';
        clear spkt spkc
        try [spkt spkc]  = DetectSpike_GC(shdat, hdr.Fs, hdr.nSamples / hdr.Fs / 60); end
        if exist('spkt')
            E(e).spkt = spkt;
            E(e).spkc = spkc;
        end

    end

    % Find spikes that are close together
    %--------------------------------------------------------------------------
    win = 0.2 * hdr.Fs;
    k   = 0;


%% Find spikes that are close together
%--------------------------------------------------------------------------
win = 0.1 * hdr.Fs;
k   = 0;
=======
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


    % Find clusters
    %----------------------------------------------------------------------
    disp('Finding clusters of spikes');
    first   = 1;
    k       = 1;
    clear gS

    for s = 1:length(Sp) - 1
        dt = Sp(s+1).t - Sp(s).t; 
        if dt > win || Sp(s).f ~= Sp(s+1).f
            if length(unique([Sp(first:s).c])) > 2
                gS(k).t = [Sp(first:s).t];
                gS(k).c = [Sp(first:s).c];
                gS(k).f = edflist{Sp(first).f};
                k       = k + 1;
            end
            first = s+1;
        end
    end
    disp(['Detected ' num2str(length(gS)) ' clusters'])

    % Plot examples (optional, as this will hold up the loop)
    %----------------------------------------------------------------------
    if doplot
        disp('Plotting - find the figure and press any key to move through plots');
        plstrt = -3 * hdr.Fs;
        plstop  = 7 * hdr.Fs;

        for g = 1:length(gS)
            thischid = chid(unique(gS(g).c));
            srt = -3 * hdr.Fs + min(gS(g).t);
            stp  = 7 * hdr.Fs + min(gS(g).t);
            dat  = ft_read_data(gS(g).f, 'begsample', srt, 'endsample', stp-1);
            dat  = dat(thischid,:);

            clf
            for d = 1:size(dat,1)
                plot(dat(d,:) + 1000*d); hold on 
            end
            title(['Plot ' num2str(g) ' of ' num2str(length(gS))])
            pause();
        end
    end

    % Plot scatter plot position v time
    %----------------------------------------------------------------------
    if doplot
        ts = [];
        for g = 1:length(gS)
            [val id] = min(gS(g).t);
            scatter(gS(g).t - val, gS(g).c - gS(g).c(id), 100, 'filled'); hold on
            ts = [ts gS(g).t - val];
        end
        set(gca, 'Xtick', 0:20:max(ts))
        set(gca, 'XTickLabel', 0:20:max(ts) * 1000 / hdr.Fs);
        ylabel('< outwards |            | inwards >')
        xlabel('time in ms');
        plot([0 Inf], [0 0], 'k');
    end
    
    % Pack up stuff you want to save from eternal damnation from the loop
    %----------------------------------------------------------------------
    SPK(ei).El = El;
    SPK(ei).gS = gS;
    SPK(ei).shk = shk;
    
end

save([Fdata fs 'SPK'], 'SPK');