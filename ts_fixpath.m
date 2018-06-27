function fpath = ts_fixpath(Fdata, f)

seps    = find(f == '/' | f == '\');
fname   = f(seps(end)+1:end);
fpath   = [Fdata filesep fname];