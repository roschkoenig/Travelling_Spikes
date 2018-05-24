function D = ts_housekeeping
fs          = filesep;
D.Fbase     = '/Users/roschkoenig/Dropbox/Research/Friston Lab/1805 Travelling Spikes/';
D.Fdata     = [D.Fbase fs 'Data'];
D.Fscripts  = [D.Fbase fs 'Scripts'];
addpath(genpath(D.Fbase));

spm('defaults', 'eeg');
