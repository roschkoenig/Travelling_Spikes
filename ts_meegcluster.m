function ts_meegcluster(sub)

fs          = filesep;
D           = ts_housekeeping;
Fdata       = [D.Fdata fs sub];
Fanalysis   = D.Fanalysis;
doplot      = 0;
clear D;

% Load channel position files
%--------------------------------------------------------------------------
load([Fdata fs sub '_chanlab.mat']);
load([Fdata fs sub '_travel_results.mat']);

% Identify electrodes of interest, for which results are available
%--------------------------------------------------------------------------
Eoi = {RES(:,1).el};

% Go through each electrode of interest
%--------------------------------------------------------------------------
for e = 1:length(Eoi) 

% Find channels for which distance is available
%--------------------------------------------------------------------------
thisEpos = find(strcmp({Epos.el}, Eoi{e}));
thisEpos = Epos(thisEpos);
roi      = find(~isnan(thisEpos.dists));

% Load dataset for electrode of interest and extract channels of interest
%--------------------------------------------------------------------------
D       = spm_eeg_load([Fdata fs 'MEEG_' sub '_' Eoi{e} '.mat']);
good    = ts_goodchan(D);
roi     = intersect(roi, good);

if ~isempty(roi)
d = D(roi,:,:);

% Run PCA to reduce dimensionality for clustering
%==========================================================================
% Reshuffle data into time(multiples) * repetition matrix for PCA
%--------------------------------------------------------------------------
nd = [];
for k = 1:size(d,1)
    nd = [nd; squeeze(d(k,:,:))];
end

% Perform PCA
%--------------------------------------------------------------------------
[pco psc pla pt2 pex] = pca(nd);
factors = find(cumsum(pex) > 90);

% Run k-means clustering on PCAs that make up 90% of variability
%==========================================================================
rng(45);

if size(d,3) > 2, k = 3;    else k = 1;     end
[clust_lab centr sumdist dist] = kmeans(pco(:,1:factors(1)), k);
realk = length(unique(clust_lab));

% Calculate average ERPs for the identified ERP clusters
%--------------------------------------------------------------------------
clear clud
clf
for c = 1:realk
%     mi = find(clust_lab == c);        % All spikes, and average within clusters
%     clud(:,:,c) = mean(d(:,:,mi), 3);

%     mi = randsample(mi,1);            % Take random selection per cluster
%     clud(:,:,c) = d(:,:,mi); 

	[val mi] = min(dist(:,c));
    clud(:,:,c)     = d(:,:,mi);
    
    % optional plotting routine
    %----------------------------------------------------------------------
    if doplot
    for j = 1:size(clud,1)
    subplot(realk,1,c), 
        plot(squeeze(clud(j,:,c)) + j*100);     hold on
    end
    if c == realk, pause; end
    end
    
end

%% Save as new MEEG object
%--------------------------------------------------------------------------
clear ftdata chtype conds
for r = 1:length(roi)
    ftdata.label{r} = num2str(thisEpos.dists(roi(r)));
    chtype{r}       = 'LFP';
end

for c = 1:size(clud,3)
    ftdata.trial{c} = clud(:,:,c);
    ftdata.time{c}  = time(D);
    conds{c}        = num2str(c);
end

D = spm_eeg_ft2spm(ftdata, [Fanalysis fs 'MEEG_' sub '_' Eoi{e} '.mat']);
D = conditions(D, 1:length(conds), conds);
D = chantype(D, 1:length(chtype), chtype);
save(D);

else 
    warning(['Skipping electrode ' Eoi{e} ' - no channels survive'])
end

end


