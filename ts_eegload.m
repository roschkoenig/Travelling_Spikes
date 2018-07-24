D   = ts_housekeeping;
fs  = filesep;

subs    = cellstr(spm_select('List', D.Fdata, 'dir', '^.*'));

%%
k = 0;
clear S

for s = 1:length(subs)
    meegs = cellstr(spm_select('FPList', [D.Fdata fs subs{s}], '^MEEG.*.mat$'));
    for m = 1:length(meegs)
        T = spm_eeg_load(meegs{m});
        und = find(meegs{m} == '_');
        dot = find(meegs{m} == '.');
        elc = meegs{m}(und(end)+1:dot(end)-1);
        
        if size(T,3) > 50 
            k = k + 1
            S(k).dat = T;
            S(k).sub = subs{s};
            S(k).fil = meegs{m};
            S(k).elc = elc;
        end
    end
end

%%

for k = 1:length(S)                    % Go through individual electrodes
    disp(['Working on dataset ' num2str(k) ' of ' num2str(length(S))]);
    d = S(k).dat(:,:,:);                % unpack data
    clear all_lag
    
    for l = 1:size(d,3)                 % Go through individual trials / spikes
        disp(['Trial ' num2str(l) ' of ' num2str(size(d,3))])
        td = squeeze(d(:,:,l));         % extract single trial data
        
        clear full_xd full_lg
        for r = 1:size(td,1)
        for c = 1:size(td,1)
            [full_xd(r,c,:) lg] = xcorr(td(r,:), td(c,:));
            [val,ind]           = max(abs(full_xd(r,c,:)));
            all_lag(l,r,c)      = lg(ind);
        end
        end 
    end
    
    S(k).lag = all_lag;
end

%% 
for k = 1:length(S)
    ml = squeeze(median(S(k).lag,1));
    imagesc(ml); 
    pause;
end