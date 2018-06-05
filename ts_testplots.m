D       = ts_housekeeping;
Fdata   = D.Fdata;
fs      = filesep;
load([Fdata fs 'SPK.mat']);

%% Load metdata
%--------------------------------------------------------------------------
[num txt rw] = xlsread(spm_select('FPList', Fdata, '^.*.xlsx$'));
[r elcol]    = find(strcmp(rw, 'electrode'));
[r nmcol]    = find(strcmp(rw, 'contact number'));

% Insert to spike information
%--------------------------------------------------------------------------
for s = 1:length(SPK)
    thise       = SPK(s).El.eoi;
    lesrow      = find(strcmp(rw(:, elcol), thise));
    SPK(s).les  = [thise num2str(rw{lesrow, nmcol})];
end

%%

locs = [];
tims = [];
k    = 0;
clear slope sS

for s = 1:length(SPK)
    gS = SPK(s).gS;
    ts = [];
    for g = 1:length(gS)
        [val id] = min(gS(g).t);
        scatter(gS(g).t - val, gS(g).c - gS(g).c(id), 100, 'filled'); hold on
        
        ts = [ts gS(g).t - val];
        
        locs = [gS(g).c - gS(g).c(id), locs];
        tims = [gS(g).t - val, tims];
        
%         lm = fitlm(gS(g).t - val, gS(g).c - gS(g).c(id));
%         if lm.Coefficients.pValue(2) < 0.05
%             k = k + 1;
%           	
%             sS(k)       = SPK(s);
%             sS(k).gS    = SPK(s).gS(g);            
%             slope(k)    = lm.Coefficients{2,1};
%         end
        
    end
    
    set(gca, 'Xtick', 0:20:max(ts))
    set(gca, 'XTickLabel', 0:20:max(ts));
    ylabel('< outwards |            | inwards >')
    xlabel('time in samples');
    plot([0 Inf], [0 0], 'k');    
end

%% Plot some average waveforms - average the first spike for each electrode
%--------------------------------------------------------------------------
k = 1;
clear sk

for s = 1:length(SPK)
    
    % Identify groups of spikes
    %----------------------------------------------------------------------
    gS      = SPK(s).gS;
    chid    = ts_shankfind(SPK(s).El);
    chid    = [chid.ind];
    cmap    = cbrewer('div', 'Spectral', length(chid));
    
    % Load data of the spikes
    %----------------------------------------------------------------------
    for g = 1:length(gS)
        seppos = find(gS(g).f == '/' | gS(g).f == '\');
        fname  = gS(g).f(seppos(end)+1:end);
        fpath  = [Fdata fs fname];
        h   = ft_read_header(fpath);
        
        % Identify starting sample and channel
        %------------------------------------------------------------------
        srt             = gS(g).t(1); 
        srt_ci          = chid(gS(g).c(1));
        
        % Translate to time window 
        %------------------------------------------------------------------
        srt             = srt - 0.2 * h.Fs;
        stp             = srt + 1 * h.Fs;
        
        % Load and preprocess data segment
        %------------------------------------------------------------------
        d   = ft_read_data(fpath, 'begsample', srt, 'endsample', stp);
        d   = ft_preproc_rereference(d);
        d   = d(chid,:);
        d   = ft_preproc_bandstopfilter(d, h.Fs, [49 51]);
        d   = ft_preproc_bandpassfilter(d, h.Fs, [1 200]);
        
        % Pack up to save beyond loop
        %------------------------------------------------------------------
        sk(s).d(g,:,:)  = d;
    end    
	sk(s).el  	= SPK(s).El.eoi;
    GD        	= ts_artifact(sk(s).d);
    sk(s).d  	= sk(s).d(GD.trl, GD.chn, :);
    sk(s).lbl   = SPK(s).El.lbl(chid(GD.chn));
    
end

%%
for s = 1:length(sk) 
    
    % Calculate mean wave forms
    %----------------------------------------------------------------------
    md      = squeeze(mean(sk(s).d,1));

    early   = fix(.175*h.Fs : .225*h.Fs); 
    mid     = fix(.250*h.Fs : .350*h.Fs);
    late    = fix(.350*h.Fs : .600*h.Fs);

    clear PK
    for m = 1:size(md,1)
        [val loc] = findpeaks(md(m,early));     PK(m).early = early(loc);   try PK(m).early = PK(m).early(1);   catch PK(m).early = NaN;    end
        [val loc] = findpeaks(md(m,mid));       PK(m).mid = mid(loc);       try PK(m).mid = PK(m).mid(1);       catch PK(m).mid = NaN;      end
        [val loc] = findpeaks(md(m,late));      PK(m).late = late(loc);     try PK(m).late = PK(m).late(1);     catch PK(m).late = NaN;     end
    end

    % Calculate distance from lesion
    %----------------------------------------------------------------------
    cllist  = regexp(sk(s).lbl, ['^[A-Z]* ' SPK(s).les '$']);
    les     = find(~cellfun(@isempty, cllist));

    clear lesdis
    for l = 1:length(sk(s).lbl);
        nm = regexp(sk(s).lbl{l}, ['\d*$']);
        thisid = str2double(sk(s).lbl{l}(nm:end));
        lesid  = str2double(sk(s).lbl{les}(nm:end));
        lesdis(l) = abs(lesid - thisid);
    end

    
    % Plotting routines
    %======================================================================
    % Scatter time vs distance from original spike
    %----------------------------------------------------------------------
    figure(1), subplot(2,1,1)
    
    scatter([PK.early]- min([PK.early]), lesdis, 100, 'filled'); hold on

    subplot(2,1,2)
    scatter([PK.late] - min([PK.late]), lesdis, 100, 'filled'); hold on


    % Plot settings
    cmap = flip(cbrewer('div', 'Spectral', max(lesdis)+1));
    figure(2), subplot(ceil(length(sk)/2),2,s)

    for m = 1:size(md,1)
        plot(md(m,:), 'color', cmap(lesdis(m)+1,:)); hold on
        xlim([1 Inf]);
    end

end


