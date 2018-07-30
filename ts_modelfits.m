D   = ts_housekeeping;
fs  = filesep;
subs    = cellstr(spm_select('List', D.Fdata, 'dir', '^.*'));
Fmeeg   = [D.Fanalysis fs 'MEEG'];
Fdcm    = [D.Fanalysis fs 'DCM'];

%%
inps = {'wm', 'cr', 'gm'};
clear P
for i = 1:length(inps)
k = 0;
for s = 1:length(subs)

    subcms = cellstr(spm_select('FPList', Fdcm, [subs{s} '_\w+_' inps{i}]));
    for c = 1:length(subcms)
        k = k + 1;k
        load(subcms{c});
        P(k,i) = DCM;
    end
end
end

%%
goods = [19 1; 34 3; ];
p   = 35;
cnd = 1;
prd = P(p,2).H{cnd};
obs = P(p,2).xY.y{cnd};

subplot(2,1,1),     for k = 1:size(prd,2),  plot(prd(:,k) + k), hold on;    end
subplot(2,1,2),     for k = 1:size(obs,2),  plot(obs(:,k) + k), hold on;    end


%%
for p = 1:size(P,1)
    for h = 1:length(P(p,1).H)
        obs = P(p,1).xY.y{h};
        prd = P(p,1).H{h};
        subplot(2,length(P(p,1).H),h), plot(prd); title(num2str(p));
        subplot(2,length(P(p,1).H),h + length(P(p,1).H)), plot(obs)
    end
    pause
end

%%
k = 0;
prd = [];
for p = 1:length(P(:,2));
for h = 1:length(P(p,2).H)
    k = k + 1;
    prd = P(p,2).H{h};
    obs = P(p,2).xY.y{h};
    lm  = fitlm(prd(:), obs(:));
    R2(k) = lm.Rsquared.Ordinary;
    if k == 99,     disp([num2str(p) ' ' num2str(h)]);  end
    
end
end


