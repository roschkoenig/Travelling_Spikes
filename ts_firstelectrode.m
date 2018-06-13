clear all
D       = ts_housekeeping;
fs      = filesep;
sub     = 'RhToLa';
Fdata   = [D.Fdata fs sub];

load([Fdata fs 'SPK.mat']);

% Go through spikes and collate first onset 
%--------------------------------------------------------------------------
mo = [];

for s = 1:length(SPK)
    
% Unpake the spiking data
%--------------------------------------------------------------------------
E = SPK(s).El;
S = SPK(s).gS;
K = SPK(s).shk;

% Go through spikes for each electrode
%--------------------------------------------------------------------------
ons_cnt = zeros(1,length(K));
allf    = [];

for ss = 1:length(S)
    [t onsid]   = min(S(ss).t);
    firsts      = find(S(ss).t == S(ss).t(onsid));
    firsts      = unique(S(ss).c(firsts));
    addto       = zeros(1,length(K));
    addto(firsts) = 1;
    ons_cnt = ons_cnt + addto; 
end

SPK(s).o    = ons_cnt;                 % Save onsets by shank
mo          = max([mo, ons_cnt]);      % Maximum values achieved by any shank (for plotting)
end

% Fit models to distributions
%--------------------------------------------------------------------------
% Model comparison 
%--------------------------------------------------------------------------
clear aic
for s = 1:length(SPK)
    o = SPK(s).o;
    n = 1:length(o);
    tab     = table(n', o', 'VariableNames', {'Space', 'Onset'});
    models  = {'Uniform', 'Gaussian', 'Quadratic', 'Higher Order'};

    % Uniform distribution
    %--------------------------------------------------------------------------
    mdl     = fitglm(tab, 'Onset~1');
    aic(1) = mdl.ModelCriterion.AIC;
    
    % Gaussian distribution
    %--------------------------------------------------------------------------
    % f(x) = 1/(sig * sqrt(2*pi)) * exp(-(x-mu)^2 / (2*sig)^2)
    f           = @(b,x) 1/(b(1) * sqrt(2*pi)) * exp(-(x(:,1) - b(2)) .^ 2 / (2*b(1))^2); 
    beta0       = [ .5, length(n)/2 ];
    mdl         = fitnlm(tab, f, beta0);
    aic(2)   = mdl.ModelCriterion.AIC;

    % Inverse quadratic distribution
    %--------------------------------------------------------------------------
    % f(x) = b(1) * x^2 + b(2) * x + b(3)
    f           = @(b,x)  b(1) * x(:,1).^2 + b(2) * x(:,1) + b(3); 
    beta0       = [ 1 1 1 ];
    mdl         = fitnlm(tab, f, beta0);
    aic(3)    = mdl.ModelCriterion.AIC;

    % higher order polynomial distribution
    %--------------------------------------------------------------------------
    % f(x) = b(1) * x^4 + b(2) * x^2 + b(3)*x + b(4)*x + b(5)
    f           = @(b,x) b(1) * x.^4 + b(2)*x.^3 + b(3)*x.^2 + b(4)*x + b(5);
    beta0       = [1 1 1 1 1];
    mdl         = fitnlm(tab,f,beta0);
    aic(4)    = mdl.ModelCriterion.AIC;

    [val loc]   = min(aic);
    winner{s}      = models{loc};

end

% Plotting histograms
%--------------------------------------------------------------------------
for k = 1:length(SPK)
    subplot(ceil(length(SPK)/2),2,k)
    bar(SPK(k).o);
    title(winner{k});
    ylim([0 mo]); 
end