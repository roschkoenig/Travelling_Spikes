function [GD BD] = ts_artifact(d) 


bad = zeros(size(d,1), size(d,2));   % matrix trials by channels

for trl = 1:size(d,1)
    td = squeeze(d(trl,:,:));
    zd = zscore(td);
    excess = abs(zd) > 3;
    excess = sum(excess,2);
    bad(trl,:) = excess > 1;
end

thr = 0.3;
chanbad     = sum(bad,1);
chantest    = chanbad > thr * size(d,1);
trltest     = sum(bad(:,~chantest),2) > 0;


BD.trl = find(trltest);     GD.trl = find(~trltest);
BD.chn = find(chantest);    GD.chn = find(~chantest);

