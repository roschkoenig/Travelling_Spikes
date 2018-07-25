function good = ts_goodchan(D)

% remove bad channels
% ----------------------------------------------------------------------
for di = 1:size(D,3)
    
    d       = squeeze(D(:,:,di));
    bltime  = find(time(D) < 0);
    bl      = d(:,bltime);
    zb      = zscore(bl);
    
    good(di,:) = sum(abs(zb) > 2.5, 2) == 0; 
    
end

good = find(sum(good) > 0.75 * size(D,3));

