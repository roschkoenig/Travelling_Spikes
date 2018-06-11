function D = ts_housekeeping
fs          = filesep;
if strcmp(computer, 'PCWIN64')
    D.Fbase     = 'C:\Users\rrosch\Dropbox\Research\Friston Lab\1805 Travelling Spikes';
else
    D.Fbase     = '/Users/roschkoenig/Dropbox/Research/Friston Lab/1805 Travelling Spikes';
end
D.Fdata     = [D.Fbase fs 'Data'];
D.Fscripts  = [D.Fbase fs 'Scripts'];
addpath(genpath(D.Fbase));

spm('defaults', 'eeg');
