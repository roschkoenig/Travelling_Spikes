function D = ts_housekeeping
fs          = filesep;
<<<<<<< HEAD

D.Fbase = '/Users/stasa.tumpa/Documents/GitHub';

% if strcmp(computer, 'PCWIN64'); 
%     D.Fbase     = 'C:\Users\rrosch\Dropbox\Research\Friston Lab\1805 Travelling Spikes';
% else
%     D.Fbase     = '/Users/roschkoenig/Dropbox/Research/Friston Lab/1805 Travelling Spikes';
% end

=======
if strcmp(computer, 'PCWIN64')
    D.Fbase     = 'C:\Users\rrosch\Dropbox\Research\Friston Lab\1805 Travelling Spikes';
else
    D.Fbase     = '/Users/roschkoenig/Dropbox/Research/Friston Lab/1805 Travelling Spikes';
end
>>>>>>> cc2f3fea57649cc696af2d3ed742a876e6ac7ec2
D.Fdata     = [D.Fbase fs 'Data'];
D.Fscripts  = [D.Fbase fs 'Scripts'];
addpath(genpath(D.Fbase));

spm('defaults', 'eeg');
