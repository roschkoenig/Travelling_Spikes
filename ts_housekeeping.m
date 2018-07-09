function D = ts_housekeeping
fs          = filesep;
% D.Fbase = '/Users/stasa.tumpa/Documents/GitHub';

if strcmp(computer, 'PCWIN64')
    D.Fbase     = 'C:\Users\rrosch\Dropbox\Research\1805 Travelling Spikes';
else
    D.Fbase     = '/Users/roschkoenig/Dropbox/Research/1805 Travelling Spikes';
end

D.Fdata     = [D.Fbase fs 'Data'];
D.Fscripts  = [D.Fbase fs 'Scripts'];
addpath(genpath(D.Fbase));

spm('defaults', 'eeg');
