function D = ts_housekeeping
fs          = filesep;
<<<<<<< HEAD
D.Fbase     = '/Users/stasa.tumpa/Documents/GitHub';
=======
if strcmp(computer, 'PCWIN64'); 
    D.Fbase     = 'C:\Users\rrosch\Dropbox\Research\Friston Lab\1805 Travelling Spikes';
else
    D.Fbase     = '/Users/roschkoenig/Dropbox/Research/Friston Lab/1805 Travelling Spikes';
end
>>>>>>> 65935f628ef17f84bb4d6db0c184f1d1fddc654d
D.Fdata     = [D.Fbase fs 'Data'];
D.Fscripts  = [D.Fbase fs 'Scripts'];
addpath(genpath(D.Fbase));

spm('defaults', 'eeg');
