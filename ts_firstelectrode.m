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
    
    clear m
    o = SPK(s).o;
    n = 1:length(o);
    tab     = table(n', o', 'VariableNames', {'Space', 'Onset'});
    models  = {'Uniform', 'Gaussian', 'Quadratic', 'Higher Order'};

    % Uniform distribution
    %--------------------------------------------------------------------------
    m(1).mdl    = fitglm(tab, 'Onset~1');
    m(1).bic    = m(1).mdl.ModelCriterion.BIC;
    
    % Gaussian distribution
    %--------------------------------------------------------------------------
    % f(x) = 1/(sig * sqrt(2*pi)) * exp(-(x-mu)^2 / (2*sig)^2)
    
    f           = @(b,x) b(3)/(b(1) * sqrt(2*pi)) * exp(-(x(:,1) - b(2)) .^ 2 / (2*b(1))^2); 
    beta0       = [10 1 1];
    m(2).mdl    = fitnlm(tab, f, beta0);
    m(2).bic    = m(2).mdl.ModelCriterion.BIC;

    [val loc]       = min([m.bic]);
    winner{s}      = models{loc};
    
  	subplot(ceil(length(SPK)/2),2,s)
        bar(SPK(s).o); hold on
        bf = (m(1).bic - m(2).bic)/2;
        title([winner{s} ' Bayes Factor: ' num2str(bf)]);
        ylim([0 mo]); 
        
        plot(predict(m(loc).mdl,n'));
        
end
