clear all;
[d, ch_names, sampling_rate] = edf_load('C:\Users\Ralph\Documents\MATLAB\Xxxxxx.edf');

% Remove Event Channel
d = d(:,2:end);
ch_names = ch_names(2:end);

% Remove non-recorded channels
Number_of_recorded_Channels = 73;
d = d(:,1:Number_of_recorded_Channels);
ch_names = ch_names(1:Number_of_recorded_Channels);

%Remove named 'dead' channels & Stim Channels
dead_channels = {'G03'; 'G16'; 'G37'; 'C64'};
stim_channels = {'DA03'; 'DA04'};

r_channels = [dead_channels; stim_channels];

for n=1:numel(r_channels)
    i = strmatch(r_channels(n),ch_names,'exact');
    d(:,i)=[];
    ch_names(i)=[];
end
 
