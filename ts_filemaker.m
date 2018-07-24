function ts_filemaker(sub)

% Load raw spike file
%--------------------------------------------------------------------------
disp(['Loading files for ' sub]);
D   = ts_housekeeping;
fs  = filesep;
Fdata   = [D.Fdata fs sub];

load([D.Fdata fs sub fs sub '_spike_groups.mat']);
hdr = ft_read_header([Fdata fs gS(1).f '.edf']);
shk = ts_shankdetect(hdr.label);


electrodes  = unique({gS.e});
ons         = -1;
win         = 3;        % data window in seconds     

for e = 1:length(electrodes)
    disp(['Going through electrode ' num2str(e) ' of ' num2str(length(electrodes)) ': ' electrodes{e}])
    
    % Generate temporary file structure
    %----------------------------------------------------------------------
    tid = find(strcmp({gS.e}, electrodes{e}));
    sid = find(strcmp({shk.name}, electrodes{e}));
    tS  = gS(tid);
   
    % go through spike groups and save relevant data in MEEG object
    %----------------------------------------------------------------------
    k = 1;
    clear ftdata
    for g = 1:length(tS)
        
        disp(['Loading set ' num2str(g) ' of ' num2str(length(tS))]);
        fname   = tS(g).f;
        srt     = fix(min([tS(g).t]) + ons*hdr.Fs);
        stp     = srt + fix(win*hdr.Fs);
        
        try
            % load data
            %------------------------------------------------------------------
            d = ft_read_data([Fdata fs tS(g).f '.edf'], 'begsample', srt, 'endsample', stp);
            d = d(sid,:); 

            ftdata.trial{k} = d;
            ftdata.time{k}  = linspace(ons + 1/hdr.Fs, ons+win, size(d,2)); 
            spkid(k)        = tid(g);
            k = k + 1;
        catch
            warning('Skipped this one');
        end
    end
    ftdata.label = hdr.label(sid);
    
    D = spm_eeg_ft2spm(ftdata, [Fdata fs 'MEEG_' sub '_' electrodes{e}]);
    save([Fdata fs sub '_spm2gS_id.mat'], 'spkid');
end

