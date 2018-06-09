function D = ts_housekeeping
fs          = filesep;
D.Fbase     = '/Users/stasa.tumpa/Documents/GitHub';
D.Fdata     = [D.Fbase fs 'Data'];
D.Fscripts  = [D.Fbase fs 'Scripts'];
addpath(genpath(D.Fbase));

spm('defaults', 'eeg');
