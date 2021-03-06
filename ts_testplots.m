sub     = 'SaKh';
D       = ts_housekeeping;
Fdata   = [D.Fdata fs sub];
fs      = filesep;
load([Fdata fs 'SPK.mat']);

% Load metdata
%--------------------------------------------------------------------------
try 
    [num txt rw]    = xlsread(spm_select('FPList', Fdata, '^.*.xlsx$'));

    elcell          = regexp(rw(1,:), '^electrode$');
    elcol           = find(~cellfun(@isempty, elcell));

    nmcell          = regexp(rw(1,:), 'contact number');
    nmcol           = find(~cellfun(@isempty, nmcell));

    % Insert to spike information
    %--------------------------------------------------------------------------
    for s = 1:length(SPK)
        thise       = SPK(s).El.eoi;
        lesrow      = find(strcmp(rw(:, elcol), thise));
        SPK(s).les  = [thise num2str(rw{lesrow, nmcol})];
    end
end

% Plot some average waveforms - average the first spike for each electrode
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
    gi = 0;
    for g = 1:length(gS)
        clear d h
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
        if srt > 1 & stp < h.nSamples
            d   = ft_read_data(fpath, 'begsample', srt, 'endsample', stp);
            d   = ft_preproc_rereference(d);
            d   = d(chid,:);
            d   = ft_preproc_bandstopfilter(d, h.Fs, [49 51]);
            d   = ft_preproc_bandpassfilter(d, h.Fs, [1 200]);
            
            % Pack up to save beyond loop
            %------------------------------------------------------------------
            gi = gi + 1;
            sk(s).d(gi,:,:)  = d;  
            
        end
        
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

%     if isfield(SPK, 'les')
%         % Calculate distance from lesion
%         %----------------------------------------------------------------------
%         cllist  = regexp(sk(s).lbl, [SPK(s).les '$']);
%         les     = find(~cellfun(@isempty, cllist));
% 
%         clear lesdis
%         for l = 1:length(sk(s).lbl)
%             nm = regexp(sk(s).lbl{l}, ['\d*$']);
%             thisid = str2double(sk(s).lbl{l}(nm:end));
%             lesid  = str2double(sk(s).lbl{les}(nm:end));
%             lesdis(l) = abs(lesid - thisid);
%         end
%     end
    
    % Plotting routines
    %======================================================================
%     % Scatter time vs distance from original spike
%     %----------------------------------------------------------------------
%     figure(1), subplot(2,1,1)
%     
%     scatter([PK.early]- min([PK.early]), lesdis, 100, 'filled'); hold on
% 
%     subplot(2,1,2)
%     scatter([PK.late] - min([PK.late]), lesdis, 100, 'filled'); hold on


    % Plot settings
    % figure(2)
    
%     if isfield(SPK, 'les'),     cmap = flip(cbrewer('div', 'Spectral', max(lesdis)+1));
% else
    cmap = flip(cbrewer('div', 'Spectral', size(md,1)));
%     end
    
    subplot(ceil(length(sk)/2),2,s)

    for m = 1:size(md,1)
%         if isfield(SPK, 'les')
%             plot(md(m,:) + 300*(m-1), 'color', cmap(lesdis(m)+1,:), 'linewidth', 2); hold on
%         else 
            plot(md(m,:) + 300*(m-1), 'color', cmap(m,:), 'linewidth', 2); hold on
%         end
        xlim([1 Inf]);
    end
    title(['Electrode ' sk(s).el])
    set(gca, 'YTick', 0:300:(300*(m-1)));
    set(gca, 'YTickLabel', sk(s).lbl);

end


