function d = ts_select(d, eoi)

label = {};
data  = [];
for e = 1:length(eoi)
    El.lbl   = d.hdr.label;
    El.eoi   = eoi{e};
    shk      = ts_shankfind(El);
    label    = [label, {shk.name}];
    data     = [data; d.trial{1}([shk.ind],:)];
end

d.trial{1}      = data;
d.label         = label;
d.hdr.label     = label;
d.hdr.chantype  = {};
d.hdr.chanunit  = {};
for k = 1:length(d.label);
    d.hdr.chantype{k} = 'EEG';
    d.hdr.chanunit{k} = 'mV';
end


