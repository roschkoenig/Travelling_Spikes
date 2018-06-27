function rdat = ts_reference(dat, varargin)

    % Re-referencing function for Thermocoagulation Dataset
    %==========================================================================
    %
    % Usage: rereferenced_data = tc_reference(data, labels, [type])
    %           type = 1: common average (default)
    %           type = 2: shank-wise average
    %           type = 3: local Laplacian average
    %           

    if nargin < 2, warning('No channel labels specified');
    else, labels = varargin{1}; end
        
    if nargin < 3,  type = 1;       else, type = varargin{2}; end

    switch type
        case 1
            rdat = tc_commonavg(dat);
        case 2
            Nref = 100;     % Range to always include all shank electrodes
            rdat = tc_localref(dat, labels, Nref);
        case 3 
            Nref = 4;    % Range of channel positions to be included in reference
            rdat = tc_localref(dat, labels, Nref);
    end
end


% Subfunctions enacting specific re-referencing routines
%==========================================================================
function rdat = tc_commonavg(dat)
    rdat = dat - mean(dat,1);
end

function rdat = tc_localref(dat, labels, Nref)

    [Nshanks Lshanks] = ts_shankno(labels);
    
    % Identify channel indices to be included in the local reference
    %--------------------------------------------------------------------------
    for l = 1:length(labels)
        thischan = labels{l};
        thisshank = Lshanks{l};

        numpos   = find(isstrprop(thischan,'digit'));
        thispos  = str2double(thischan(numpos));

        chani_on_shank = find(strcmp(thisshank, Lshanks));

        clear Ref
        i = 0;

        % Identify the close neighbours on this shank
        %----------------------------------------------------------------------
        clear dist
        for c = 1:length(chani_on_shank)

            loopchan = labels{chani_on_shank(c)};
            numpos   = find(isstrprop(loopchan,'digit'));
            looppos  = str2double(loopchan(numpos));

            dist(c) = looppos - thispos;
            if abs(dist(c)) <= Nref && dist(c) ~= 0
                i   = i + 1;
                Ref(i).chani    = chani_on_shank(c);
                Ref(i).pos      = looppos;
                Ref(i).dist     = dist(c);
            end   
        end

        % If no close neighbours - find closest and do bipolar 
        %----------------------------------------------------------------------
        if exist('Ref') ~= 1        
            [val ind] = min(abs(dist(dist > 0)));
            loopchan = labels{chani_on_shank(ind)};
            numpos   = find(isstrprop(loopchan,'digit'));
            looppos  = str2double(loopchan(numpos));

            Ref.chani   = chani_on_shank(ind);
            Ref.pos     = looppos;
            Ref.dist    = looppos - thispos;
        end


        R{l} = Ref;
    end

    % Set up rereferencing weights
    %--------------------------------------------------------------------------

    mu      = 0;
    sigma   = 2;

    bip     = zeros(1,length(R));
    for r = 1:length(R)
        Ref = R{r};
        x   = [Ref.dist];
        y   = normpdf(x, mu, sigma);
        y   = y / sum(y);
        if length(y) == 1
            bip(r)  = 1;
        end

        for rr = 1:length(Ref)
            Ref(rr).weights = y(rr);
        end
        R{r}            = Ref;

    end

    % Calculate new references
    %--------------------------------------------------------------------------
    clear rdat
    for r = 1:length(R)

        dd          = dat([R{r}.chani],:);
        ww          = [R{r}.weights];
        rdat(r,:)   = dat(r,:) - [ww * dd];

    end
end

