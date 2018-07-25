function ts_chanmatch(sub)
fs    	= filesep;
D       = ts_housekeeping;
Fdata   = [D.Fdata fs sub];

% Load files and headers 
%--------------------------------------------------------------------------
load([Fdata fs 'DEL_' sub '.mat']);

chancond = load([D.Fdata fs 'Channel_Labels.mat']);
chancond = chancond.A;

orig    = cellstr(spm_select('FPList', Fdata, ['^' sub '.*\.(edf|EDF)$']));
o_hdr   = ft_read_header(orig{1});

bip     = cellstr(spm_select('FPList', Fdata, ['^p' sub]));
hdr     = ft_read_header(bip{1});


cc = chancond(strcmp({chancond.name}, sub));
clear Epos

for e = 1:length({cc.el})
    clear wm gm cr dists
    clear pos
    bad = 0;
    
    % Find delay list that matches electrode
    %----------------------------------------------------------------------
    thise   = cc(e).el;
    shanki  = find(~cellfun(@isempty,regexp(hdr.label, ['^' thise '\d+'])));
	for d = 1:length(shanki), dists(d) = NaN; end 
    
    clear lpos
    for l = 1:length(L)
        foundcells = regexp(L(l).chans, ['^' thise '\d+-' thise]);
        lpos(l)    = sum(cellfun(@isempty, foundcells)) == 0;
    end
    if sum(lpos) > 1,   error('Didn''t find the right number of channels'); end
    thisL = L(lpos);
    
    % Find channel positions from original file
    %----------------------------------------------------------------------
    try 
        wm_o = find(~cellfun(@isempty,regexp(o_hdr.label, ['^' cc(e).el '0*' num2str(cc(e).wm) '$'])));
        cr_o = find(~cellfun(@isempty,regexp(o_hdr.label, ['^' cc(e).el '0*' num2str(cc(e).cr) '$'])));
        gm_o = find(~cellfun(@isempty,regexp(o_hdr.label, ['^' cc(e).el '0*' num2str(cc(e).gm) '$'])));
    catch
        bad = 1;
    end
    if isempty(wm_o) || isempty(cr_o) || isempty(gm_o), bad = 1; end
    
    % Match channel positions with bipolar montage
    %----------------------------------------------------------------------
    try
        wm = find(~cellfun(@isempty,regexp(hdr.label, ['(^' o_hdr.label{wm_o} ')|(\d+-' o_hdr.label{wm_o} '$)'])));
        cr = find(~cellfun(@isempty,regexp(hdr.label, ['(^' o_hdr.label{cr_o} ')|(\d+-' o_hdr.label{cr_o} '$)'])));
        gm = find(~cellfun(@isempty,regexp(hdr.label, ['(^' o_hdr.label{gm_o} ')|(\d+-' o_hdr.label{gm_o} '$)'])));

        if      min(wm) < min(gm),  wm = min(wm);   gm = max(gm); 
        else                        wm = max(wm);   gm = min(gm);   end
        
        if length(cr) > 1
            uniq = ~ismember(cr, [gm,wm]);
            cr   = cr(uniq);
        end
        cr = cr(1);
        
    catch
        bad = 1;
    end
   
    if bad
        pos(1:3) = NaN;
        disp(['Could not match up channels for ' cc(e).el]);
    else 
        pos(1) = wm;
        pos(2) = cr;
        pos(3) = gm;
    
        % Full list of channel distances from core
        %----------------------------------------------------------------------
        if wm < gm
            srt = find(shanki == wm);
            ds  = [wm:gm]-cr;
            dists(srt:srt+length(ds)-1) = ds;
        else
            srt = find(shanki == gm);
            ds  = ([gm:wm]-cr)*(-1);
            dists(srt:srt+length(ds)-1) = ds;
        end
    end

    Epos(e).pos = pos;
    Epos(e).el  = thise;
    Epos(e).shanki = shanki;
    Epos(e).dists  = dists;
end

save([Fdata fs sub '_chanlab.mat'], 'Epos');
