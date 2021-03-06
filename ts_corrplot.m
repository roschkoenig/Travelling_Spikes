D   = ts_housekeeping;
sub = 'JoDa';
fs  = filesep;

Fmeeg = [D.Fanalysis fs 'MEEG'];
meegs = cellstr(spm_select('FPList', Fmeeg, ['^MEEG_' sub '.*\.mat'])); 

%%
m = 1;  % meegfile (i.e. electrode)
t = 3;  % trial (i.e. spike number)
ysc = 200;  % y-scale factor (separates individual traces in EEG)

M   = spm_eeg_load(meegs{m});
Fs  = fsample(M);
tcs = [1:length(chanlabels(M))] * ysc;
pos = str2double(chanlabels(M));

cols = flip(cbrewer('div', 'Spectral', max(abs(pos))*2 + 1));
% cmap = parula(max(abs(pos))*2 + 1);
cmapi = -max(abs(pos)) : max(abs(pos));

for r = 1:size(M,1)
    [val cr] = min(abs(pos));
    col = cols(find(cmapi == pos(r)),:);
    
    subplot(2,3,1:3)
        plot([0:size(M,2)-1]/Fs, M(r,:,t) + r*ysc, 'color', col, 'linewidth', .75)
        xlabel('Time in seconds', 'fontsize', 10, 'fontweight', 'bold');
        ylabel(' white matter <--> grey matter', 'fontsize', 10, 'fontweight', 'bold'); 
        title('SEEG signal (bipolar montage)','fontsize', 12, 'fontweight', 'bold');
        hold on
        set(gca, 'YTick', tcs, 'YTickLabel', chanlabels(M));
   
    [xc lags] = xcorr(M(cr,:,t), M(r,:,t));
    
    subplot(2,3,4:5)
        plot(lags/Fs, xc, 'color', col, 'linewidth', .75), hold on;
        title('Cross correlation (in relation to core channel)', 'fontsize', 12, 'fontweight', 'bold');
        xlabel('Delay in seconds', 'fontsize', 10, 'fontweight', 'bold');
        ylabel('Cross correlation', 'fontsize', 10, 'fontweight', 'bold');
        
    subplot(2,3,6)
        tim = lags/Fs;
        plot(tim, xc, 'color', col, 'linewidth', .75), hold on;
        title('Cross correlation (detail)','fontsize', 12, 'fontweight', 'bold');
        xlabel('Delay in seconds', 'fontsize', 12, 'fontweight', 'bold');
        ylabel('Cross correlation', 'fontsize', 12, 'fontweight', 'bold');
        
        win     = [-0.1 0.1];
        wini    = intersect(find(tim > win(1)),find(tim < win(2)));
        [val ind] = max(abs(xc(wini)));
        plot([tim(wini(ind)) tim(wini(ind))],[sort([0 xc(wini(ind))])], 'color', col, 'linewidth', .75)
        
        xlim(win)
        
    set(gcf, 'color', 'w');

end

