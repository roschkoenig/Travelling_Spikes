function good = ts_goodchan(D)

% remove bad channels
% ----------------------------------------------------------------------
for di = 1:size(D,3)
    
    d       = squeeze(D(:,:,di));
    bltime  = find(time(D) < 0);
    bl      = d(:,bltime);
    zb      = zscore(bl);
    
    bad(di,:)    = mean(abs(D(:,:,di)),2) > 1000;
    good(di,:) = sum(abs(zb) > 2.5, 2) == 0; 
    
end
bad  = max(bad);
good = sum(good) > 0.75 * size(D,3);
good = good - bad;
good = find(good);

