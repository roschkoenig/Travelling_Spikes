function shk = ts_shankfind(El)
k = 0;
clear shk

for l = 1:length(El.lbl)
    rx = [El.eoi '\d'];
    id = regexp(El.lbl{l}, rx);  
    if ~isempty(id)
        k = k + 1;
        shk(k).name = El.lbl{l}(id(1):end);
        shk(k).ind  = l;
    end
end