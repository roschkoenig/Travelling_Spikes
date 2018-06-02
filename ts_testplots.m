locs = [];
tims = [];
k    = 0;
clear slope

for s = 1:length(SPK)
    gS = SPK(s).gS;
    ts = [];
    for g = 1:length(gS)
        [val id] = min(gS(g).t);
        scatter(gS(g).t - val, gS(g).c - gS(g).c(id), 100, 'filled'); hold on
        ts = [ts gS(g).t - val];
        
        locs = [gS(g).c - gS(g).c(id), locs];
        tims = [gS(g).t - val, tims];
        
        lm = fitlm(gS(g).t - val, gS(g).c - gS(g).c(id));
        if lm.Coefficients.pValue(2) < 0.05
            k = k + 1;
            slope(k) = lm.Coefficients{2,1};
        end
        
    end
    
    set(gca, 'Xtick', 0:20:max(ts))
    set(gca, 'XTickLabel', 0:20:max(ts) * 1000 / hdr.Fs);
    ylabel('< outwards |            | inwards >')
    xlabel('time in ms');
    plot([0 Inf], [0 0], 'k');    
end

%% Plot some average waveforms - average the first spike for each electrode
%--------------------------------------------------------------------------
for s = 1:length(SPK)
    gS = SPK(s).gS;
    
end