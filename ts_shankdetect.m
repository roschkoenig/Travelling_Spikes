function shk = ts_shankdetect(label)

foundit = 0;
eltype(1).name  = 'referential';
eltype(1).reg   = ['^([a-z]|[A-Z]|''|-)+\d+-([a-z]|[A-Z]|''|-)+\d+'];


for e = 1:length(eltype)
    xpdet = regexp(label,eltype(e).reg);
    detected = ~cellfun(@isempty,xpdet);
    
    if sum(detected) == length(label),  foundit = e;
    end
end
  
if foundit,     disp(['I think the montage is ' eltype(e).name]); 
else error('Couldn''t automatically detect the montage type'); end

clear shk
switch eltype(foundit).name
    case 'referential'
        xp = '\d';
        dt = regexp(label, xp);  
        for d = 1:length(dt)
            shk(d).name = label{d}(1:(dt{d}(1)-1));
        end
        
        labs = unique({shk.name});
        for d = 1:length(shk)
            shk(d).ind = find(strcmp(labs,shk(d).name));
        end
end
