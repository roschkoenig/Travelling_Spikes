function [Nshanks Lshanks] = ts_shankno(labels)
    
for l = 1:length(labels)
    letterpos   = find(isstrprop(labels{l},'alpha'));
    chars{l}    = labels{l}(letterpos);
end

Nshanks = length(unique(chars));
Lshanks = chars;