function ts_delaystats(sub)

fs    	= filesep;
D       = ts_housekeeping;
Fdata   = [D.Fdata fs sub];

% Load relevant data files
%--------------------------------------------------------------------------
load([Fdata fs sub '_chanlab.mat']);    % Epos variable with electrode positions (white matter, core, grey matter)
load([Fdata fs 'DEL_' sub '.mat']);     % 'L' variable, containing delays for low and high frequencies > change to DEL
DEL = L; clear L

bip = cellstr(spm_select('FPList', Fdata, '^p.*(edf|EDF)'));
hdr = ft_read_header(bip{1});

% Find eligible electrodes - both delay and MRI position info
%--------------------------------------------------------------------------
for l = 1:length(DEL)
    numi = regexp(DEL(l).chans{1}, '[0-9]');
    Lname{l} = DEL(l).chans{1}(1:numi(1)-1);    
end

eind = zeros(1,length(Epos));
for e = 1:length(Epos)
E   = Epos(e);
if sum(isnan(E.pos) == 0) && ~isempty(find(strcmp(Lname, E.el)))
    lind(e) = find(strcmp(Lname, E.el));
end
end

% Collate all relevant data
%--------------------------------------------------------------------------
k = 0;
clear DSM
for e = find(lind ~= 0)
    k = k + 1;
    
    DSM(k).e    = Lname{lind(e)};
    DSM(k).L    = DEL(lind(e),:);
    
    clear si
    for c = 1:length(DSM(k).L(1).chans)
        ch      = DSM(k).L(1).chans{c};
        si(c)   = find(strcmp(hdr.label(Epos(e).shanki), ch));
    end
    
    DSM(k).dists = Epos(e).dists(si);
    
    if length(find(~isnan(DSM(k).dists))) <= 4
        DSM = DSM(1:k-1); 
        k   = k - 1;
    end
        
end


for k = 1:length(DSM)
for f = 1:length(DSM(k).L)
    roi = ~isnan(DSM(k).dists);
   
    del = DSM(k).L(:,f).del; 
    models  = {'Uniform', 'G2W', 'Cout'};   
    
    % Uniform distribution
    %--------------------------------------------------------------------------
    ydis = []; xdel = [];
    for d = 1:size(del,2)
        xdel = [xdel; del(roi,d)];
        ydis = [ydis; DSM(k).dists(roi)'];
    end
    tab     = table(ydis, xdel, 'VariableNames', {'Distance', 'PhaseDelay'});
    
    m(1).mdl    = fitglm(tab, 'Distance~1');
    m(1).bic    = m(1).mdl.ModelCriterion.BIC;
    m(1).name   = models{1};
    
    % Along grey-white matter axis
    %--------------------------------------------------------------------------
    xdel = []; ydis = [];
    for d = 1:size(del,2)
        xdel = [xdel; del(roi,d)];
        ydis = [ydis; DSM(k).dists(roi)'];
    end
    tab     = table(ydis, xdel, 'VariableNames', {'Distance', 'PhaseDelay'});
    
    m(2).mdl    = fitglm(tab, 'Distance~PhaseDelay');
    m(2).bic    = m(2).mdl.ModelCriterion.BIC;
    m(2).name   = models{2};
    
    % From core out
    %--------------------------------------------------------------------------
    xdel = []; ydis = [];
    for d = 1:size(del,2)
        xdel = [xdel; del(roi,d)];
        ydis = [ydis; abs(DSM(k).dists(roi))'];
    end
    tab     = table(ydis, xdel, 'VariableNames', {'Distance', 'PhaseDelay'});
    
    m(3).mdl    = fitglm(tab, 'Distance~PhaseDelay');
    m(3).bic    = m(3).mdl.ModelCriterion.BIC;
    m(3).name   = models{3};    
    
    RES(k,f).m      = m;
    RES(k,f).el     = DSM(k).e;
end
end

save([Fdata fs sub '_travel_results'], 'RES');