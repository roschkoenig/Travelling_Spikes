% function ts_summarystats(subs)

fs    	= filesep;
D       = ts_housekeeping;

ALL = [];
for s = 1:length(subs)
    sub = subs{s};
    Fdata   = [D.Fdata fs sub];
    
    load([Fdata fs sub '_travel_results.mat'])
    for r = 1:size(RES,1)
    for f = 1:size(RES,2)
        RES(r,f).sub = sub;
    end
    end
    
    ALL = [ALL;RES];
end

%%
clear bay
for f = 1:size(ALL,2);
for a = 1:size(ALL,1)
    bic         = [ALL(a,f).m.bic];
    [val ind]   = min(bic);
    
    [srt stg] = sort(bic);
    b = exp((srt(2) - srt(1)));   % calculated according to Nagin (1999)
    
    bay(a,f).b = b;
    bay(a,f).m = ind;
    bay(a,f).bic = bic;
end
end

%%
allb = vertcat(bay(:,1).bic);
% allb = allb - min(allb')';

%% 
frq = {'slow', 'fast'};
for f = 1:2
subplot(2,1,f)
    mbic = nanmean(vertcat(bay(:,f).bic));
    mbic = mbic
    bar(mbic)
    set(gca, 'XTick', 1:length(mbic));
    set(gca, 'XTickLabel', {ALL(1).m.name});
    ylabel('BIC value');
    title(['Model Comparison for ' frq{f} ' frequency phase delays'])
end

%%
freqs = {'low frequency', 'high frequency'};

for f = 1:size(ALL,2)
for a = 1:size(ALL,1)
    slopes(a)   = ALL(a,f).m(3).mdl.Coefficients.Estimate(2);
    pvals(a)    = ALL(a,f).m(3).mdl.Coefficients.pValue(2); 
    
    [srt stg] = sort(slopes);
    SLL = ALL(stg,1);
end

[p h stat] = signrank(slopes);
WIL(f).stat = stat;
WIL(f).p    = p;
WIL(f).name = freqs;

end




