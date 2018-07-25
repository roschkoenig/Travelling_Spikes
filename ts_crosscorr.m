function ts_crosscorr(sub)
% sub = 'AlCo';

fs    	= filesep;
D       = ts_housekeeping;
Fdata   = [D.Fdata fs sub];

meegfiles = cellstr(spm_select('FPList', Fdata, '^MEEG.*mat$'));
clear L

for m = 1:length(meegfiles)
    
    % Load files
    %----------------------------------------------------------------------
    D = spm_eeg_load(meegfiles{m});
    
	% Elaborate way of finding out channel name
    %----------------------------------------------------------------------
    name = fname(D);
    seppos = find(name == '_');
    dotpos = find(name == '.');
    el = name(seppos(end)+1:dotpos(1)-1);
    disp(['Working on electrode ' el]);
    
	% Find good channels
    %----------------------------------------------------------------------
    chans = chanlabels(D);
    good = ts_goodchan(D);
    chans = chans(good);
   	
    % calculate frequency band specific cross-correlation
    %----------------------------------------------------------------------
    Fbp     = [1 13; 13 100];
    clear F
    for f = 1:size(Fbp,1)
        d = D(good,:,:);
        for di = 1:size(d,3)
            td = squeeze(d(:,:,di));
            td = ft_preproc_bandpassfilter(td, fsample(D), Fbp(f,:), 4, 'brickwall');
            F(f).d(:,:,di) = td;
        end
    end

    clear del
    for f = 1:length(F)
    for k = 1:size(d,3) 
        td = squeeze(F(f).d(:,:,k));
        md = mean(td,1);
        
        clear delmat
        for r = 1:size(td,1)
        for c = 1:size(td,1)
            delmat(r,c) = finddelay(td(r,:), td(c,:)); % r = reference vector
        end
        end
        del(f,:,k) = mean(delmat,2);                   % delay on average compared to all reference vectors
        
    end
    end
    
    for f = 1:size(del,1)
        L(m,f).del    = squeeze(del(f,:,:));
        L(m,f).mdl    = mean(squeeze(del(f,:,:)),2);
        L(m,f).chans  = chans;
    end
   
    clear del mdl chans
end
    
save([Fdata fs 'DEL_' sub], 'L');
