function ts_preproc(sub)

D           = ts_housekeeping;
fs          = filesep;
Fdata       = [D.Fdata fs sub];
downsample  = 0;

fs      = filesep;
edfs    = cellstr(spm_select('List', Fdata, ['^' sub '_.*(edf|EDF)']));  % Find unprocessed EDF files
P       = ts_patients(sub); 

if isempty(edfs),   error('Couldn''t find the right files (need to start with subject name)'); end

for e = 1:length(edfs)
    disp(['Loading file ' num2str(e) ' of ' num2str(length(edfs))]);

    % Standard preprocessing: filter and detrend
    %----------------------------------------------------------------------
    clear cfg
    cfg.dataset     = [Fdata fs edfs{e}];
    cfg.continuous  = 'yes';
    
    cfg.bpfilter    = 'yes';
    cfg.bpfreq      = [0.1 120];
    
    cfg.bsfilter    = 'yes';
    cfg.bsfreq      = [49 51];
    cfg.detrend     = 'yes';
    
    d               = ft_preprocessing(cfg); 
    
    % Downsample: 
    %----------------------------------------------------------------------
    if downsample
        clear cfg
        cfg.resamplefs  = 256;
        cfg.detrend     = 'yes';
        cfg.demean      = 'yes';
        cfg.feedback    = 'textbar';
        
        d           = ft_resampledata(cfg,d);
        d.hdr.Fs    = cfg.resamplefs;
    end
    
    % Select only electrodes of interest
    %----------------------------------------------------------------------
    d               = ts_select(d, P.eoi); 
    mont            = ts_montage(d.hdr);
    
    rd              = ft_apply_montage(d, mont);
    rd.hdr.label    = rd.label;
    rd.hdr.nChans   = length(rd.label);
    rd.hdr.chantype = rd.hdr.chantype(1:length(rd.label));
    rd.hdr.chanunit = rd.hdr.chanunit(1:length(rd.label));
    rd.hdr.nSamples = size(rd.trial{1},2);
    
    % Save data
    %----------------------------------------------------------------------
    ft_write_data([Fdata fs 'p' edfs{e}], rd.trial{1}, 'header', rd.hdr, 'dataformat', 'edf');
end
