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

%%
PFull = P(:,2);
PForw = PFull;

for p = 1:length(PFull)
    
    [val core] = min(abs(str2double(PForw(p).Sname)));
    val        = str2double(PForw(p).Sname{core});
    deep       = find(str2double(PForw(p).Sname) < val);
    supf       = find(str2double(PForw(p).Sname) > val);
    
    OF = zeros(size(PFull(p).A{1}));
    OB = zeros(size(PFull(p).A{2}));
    IF = zeros(size(PFull(p).A{1}));
    IB = zeros(size(PFull(p).A{2}));
    
    if min(deep) < core
    for d = 1:length(deep), dd = deep(d); OF(dd,dd+1) = 1; IB(dd+1,dd) = 1; end
    for s = 1:length(supf), ss = supf(s); OB(ss,ss-1) = 1; IF(ss-1,ss) = 1; end
    else
	for d = 1:length(deep), dd = deep(d); OB(dd,dd-1) = 1; IF(dd-1,dd) = 1; end
    for s = 1:length(supf), ss = supf(s); OF(ss,ss+1) = 1; IB(ss+1,ss) = 1; end
    end
    
    % Full model
    R{p,1} = PFull(p);
    
    % Outwards from core
    %----------------------------------------------------------------------
    m       = 2;
    R{p,m} = PFull(p); 
    R{p,m}.M.pC.A{2}     = OF;
    R{p,m}.M.pC.A{1}     = OB;
   
    B = {};
    for b = 1:length(PFull(p).B)
        for d = 1:size(PFull(p).B,1), B{b} = zeros(size(PFull(p).B{b})); B{b}(d,d) = 1;  end
        B{b}    = B{b} + OF + OB; 
    end
    R{p,m}.M.pC.B    = B;
    
   	% Inwards from core
    %----------------------------------------------------------------------
    m      = 3;
    R{p,m} = PFull(p); 
    R{p,m}.M.pC.A{2}     = IF;
    R{p,m}.M.pC.A{1}     = IB;
   
    B = {};
    for b = 1:length(PFull(p).B)
        for d = 1:size(PFull(p).B,1), B{b} = zeros(size(PFull(p).B{b})); B{b}(d,d) = 1;  end
        B{b}    = B{b} + IF + IB; 
    end
   
    R{p,m}.M.pC.B    = B;

end
        
%%

[BMR, BMC, BMA] = spm_dcm_bmr(R);

%%
[post,exp_r,xp,pxp,bor] = spm_dcm_bmc(BMR);

