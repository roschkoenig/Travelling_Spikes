% makes average EEG of events detected on the EMG channel from gap free recording
%clear all

disp('choose edf file')
% upload the edf file of left eye
[edfname, edfpath]=uigetfile('*.edf','Select a data file','Multiselect','off');	%Open the windows file open interface - Allow multiple files
cd (edfpath)	%Change the drive to the required file path


[d, ch_names, sampling_rate] = edf_load(edfname);

%% load EMG channels

str = 'emg'
emg_ch_no = find(strncmpi(str,ch_names,3)==1);

for i=1:size(emg_ch_no,1)
    emg(:,i) = d(:,emg_ch_no(i));
end

%% use spike detect to get EMG CMAPs

% using Barkmeier et al for spike detection.
% set up parameters for spike detection

Fs = 500; % ampling frequency
BlockSize = 1; % block of EMG to analyse in minutes
SCALE = 70; % normalisation scale
STDCoeff = 4; %4x mean
DetThresholds = [5; 5; 600; 10; 10]; %L/R slope, amp, L/R dur in ms [7 7 600 10 10]
TroughSearch = 40; %ms
FilterSpec = [20; 50; 1; 35;] % filter specifications hp/lp/hp/lp

for i=1:size(emg,2)
    [SpikeIndex{i}, ChanId{i}, SpikeFV{i} EffScale{i}] = DetectSpike_GC(emg(:,i), Fs, BlockSize, SCALE, STDCoeff, DetThresholds, FilterSpec, TroughSearch);
end

%% plot estimated spikes
T = 1; % period of pre and post EMG to visually plot
win0 = -(T.*Fs):1:(Fs.*T); % window to plot
for i=1:size(SpikeIndex,1)
    for j=1:size(SPikeIndex{i},1)
        if SpikeIndex{i}(j,1)>T.*Fs & (SpikeIndex{i}(j,1)  + T.*Fs)<size(emg,1)
            win{i}(:,j) = SpikeIndex{i}(j,1) + win0
            title(['EMG channel ',num2str(i),' ; Trial ',num2str(j)])
            plot(win0,emg(win{i}(:,j),i))
            pause
        end
    end
end


%% remove faulty EMG CMAPs

% h{i} = ??
for i=1:size(h,1)
    SpikeIndex{i}(h{i},:)=[];
end
clear win
% Create new windows
for i=1:size(SpikeIndex,1)
    for j=1:size(SPikeIndex{i},1)
        if SpikeIndex{i}(j,1)>T.*Fs & (SpikeIndex{i}(j,1)  + T.*Fs)<size(emg,1)
            win{i}(:,j) = SpikeIndex{i}(j,1) + win0
            
        end
    end
end
%% average on EEG

for i=1:size(SpikeIndex,1)
    for j=1:size(SpikeIndex{i},1)
        EEG_trial{i}(j,:,win{i}(:,j)) = d(:,win{i}(:,j));
        
    end
end

for i=1:size(EEG_trial,1)
    mEEG(i,:,:) = squeeze(nanmean(EEG_trial{i},1));
end

%% plot averaged EEG including EMG channels

for i=1:size(mEEG,1)
    
    subplot(1,size(mEEG,1),i)
    
    hold on
    for j=1:size(mEEG,2)
        plot(win0,squeeze(mEEG(i,j,:)) + j.*1000)
    end
    
end
