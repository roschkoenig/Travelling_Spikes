function montage = ts_montage(h)

digid = regexp(h.label, '\d*$');
clear allname
for n = 1:length(h.label)
    allnames{n} = h.label{n}(1:digid{n}-1);
end

names = unique(allnames);

E.lbl = h.label;
E.eoi = names{1};
shk   = ts_shankfind(E);

% make M * N montage (M = new; N = old)
E.lbl   = h.label;
tra    = [];
n       = 0;

for ei = 1:length(names)
    E.eoi   = names{ei};
    shk     = ts_shankfind(E);
    
    for i = 2:length(shk)
        n = n + 1;
        tra(n, shk(i-1).ind) = 1;
        tra(n, shk(i).ind) = -1;
        lbl{n}                = [shk(i-1).name '-' shk(i).name];
    end
end

montage.tra         = tra;
montage.labelold    = h.label;
montage.labelnew    = lbl;

    