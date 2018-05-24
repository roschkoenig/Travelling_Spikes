% makes average EEG of events detected on the EMG channel from gap free recording
%clear all

disp('choose edf file')
% upload the edf file of left eye
[edfname, edfpath]=uigetfile('*.edf','Select a data file','Multiselect','off');	%Open the windows file open interface - Allow multiple files
cd (edfpath)	%Change the drive to the required file path


[d, ch_names, sampling_rate] = edf_load(edfname);

% find stimulation times from the EMG channel using Hilbert transform
%EMGchannel1=d(:,31);
%EMGchannel2=d(:,33);
%EMGbipol=EMGchannel1-EMGchannel2;
EMGchannel1=d(:,30);
EMGchannel2=d(:,32);
EMGbipol=EMGchannel1-EMGchannel2;

% high pass filtering of EMG in order get rid of movement artefact
SF=1024;
W1=5./round(SF/2); 
[b1,a1] = cheby2(2,20,W1,'high');
EMGbipolFilt=filtfilt(b1,a1,EMGbipol);
figure
hold all
plot(EMGbipol)
plot(EMGbipolFilt,'r')

EMGbipolHilb=abs(hilbert(EMGbipolFilt));
EMGbipolHilb=smooth(EMGbipolHilb);
plot(EMGbipolHilb,'k')

thr=mean(EMGbipolHilb)+1*std(EMGbipolHilb);

StimTime=find(EMGbipolHilb>thr);
%FirstStimTime=StimTime(1);
StimTimeDiff=diff(StimTime);
%StimTimeDiff(1)=[0];
InterStimIntervals=find(StimTimeDiff>300);%estimate the minimal interval between myocloni - samples roughly correspond to time in ms
%FirstInterStimIntervals=InterStimIntervals(1);

StimTime1=StimTime(InterStimIntervals+1);
StimTime = StimTime1;
%StimTime=[FirstStimTime;StimTime];

%[pks StimTime]=findpeaks(EMGbipolFilt,'minpeakheight',thr,'minpeakdistance',3*SF);
% hold on 
% scatter(StimTime,'k')

% find out number of stimuli detected
N=length(StimTime);
disp('number of detected myocloni is ');
disp(N)

%---------------------------------------------------------
% get rid of channels not used for EEG
d=d(:,2:29);
d(:,21)=[]; % unused channels - Fpz
% d(:,17:18)=[]; % unused channels

ch_names=ch_names(2:29);
ch_names(21)=[];
%ch_names=strrep(ch_names,'Fpz','Oz');
%----------------------------------------------------------
%--------------------------------------------------------------------------
% AVERAGE STIMULATION EEG
% snip the individual sweeps from the matrix recorded gap-free

%count the channels used
dsize=size(d);

ArrayOneEvent=[];
ArrayOneEventConcat=[];
  
for ind=1:length(StimTime)
    ArrayOneEvent=d(StimTime(ind)-256:StimTime(ind)+256,:);
      
    ArrayOneEventConcat=cat(3,ArrayOneEventConcat,ArrayOneEvent);
end

% grand average
AverageStim=mean(ArrayOneEventConcat,3);

% normalise average stim train
MaxOfMatrix=max(max(AverageStim));
AverageStimN=AverageStim/MaxOfMatrix;

% IF DESIRED INCREASE EEG PLOT n-FOLD
n=1;
AverageStimN=n.*AverageStimN;

% % set the swaying baseline to 0
% baselinedrift=AverageStimN(1:64,:);
% baselinedrift=mean(baselinedrift,1);
% baselinedrift=repmat(baselinedrift,length(ArrayOneEventConcat),1);
% AverageStimN=AverageStimN-baselinedrift;

% set offset for EEG plot
%OffsetMatrix=[1:dsize(2)];
OffsetMatrix=[dsize(2):-1:1];
OffsetMatrix=repmat(OffsetMatrix,513,1);


%AverageStim for plot
AverageStimForPlot=AverageStimN+OffsetMatrix;

% plot averaged eeg (figure 1)
figure;
hold all 

plot(AverageStimForPlot,'k','linewidth',2)

title(['Backaveraged EEG'])

xlim([0 513])
set(gca, 'xtick',[1:128:513])  
set(gca, 'xtickLabel',{'-0.25','-0.125','0','0.125','0.25'})

set(gca, 'ytick',[1:1:dsize(2)])  

set(gca, 'ytickLabel',ch_names(end:-1:1))

set(gca,'FontSize',6)

xlabel('Time (s)')
ylabel('Channels')
ylim([-1 dsize(2)+2])

% plot vertical line to mark the stimulation
hold on
a=[256 256];
b=[1 dsize(2)];
plot(a,b,'k')   

% % find the P100
% [P100ampli P100sample]=min(AverageStimN(166:197,21));
% P100sample=P100sample+166;
% P100delay=(P100sample-64)/1.024;
% disp('P100 delay is ');
% disp(P100delay)
% 
% % brain map (figure 2)
% map=AverageStimN(P100sample-4:P100sample+5,:);
% map=mean(map,1);
% map=[0 0 0 map(1) 0 map(12) 0 0 0; 0 map(23) map(2) map(6) map(10) map(17) map(13) map(24) 0;...
%     map(9) map(3) map(25) map(7) map(11) map(18) map(26) map(14) map(20);...
%     0 map(23) map(4) map(8) map(22) map(19) map(15) map(28) 0;...
%     0 0 0 map(5) map(21) map(16) 0 0 0];
% % map=reshape(map,9,5);
% % map=map';
% map=-map;
% figure
% imagesc(map)
% colorbar('location','southoutside')
% caxis([-1 1])
% title(['Left eye'])
% 
% %---------------------------------------------------------------------------
% disp('choose the right eye edf file')
% % upload the edf file of right eye
% [edfname, edfpath]=uigetfile('*.edf','Select a data file','Multiselect','off');	%Open the windows file open interface - Allow multiple files
% cd (edfpath)	%Change the drive to the required file path
% 
% 
% [dR, ch_names, sampling_rate] = edf_load(edfname);
% % get rid of unused channels
% dR=dR(:,1:29);
% % d(:,25:26)=[]; % unused channels
% % d(:,17:18)=[]; % unused channels
% 
% 
% 
% % find stimulation times
% stimchannelR=dR(:,1);
% thr=0.5;
% % StimTime=find(channAverage>maxvalue*thr);
% [pks StimTimeR]=findpeaks(stimchannelR,'minpeakheight',thr);
% 
% % find out number of stimuli detected
% NR=length(StimTimeR);
% disp('number of detected stimuli is ');
% disp(NR)
% 
% 
% %--------------------------------------------------------------------------
% % AVERAGE STIMULATION EEG
% % snip the individual sweeps from the matrix recorded gap-free
% dR=dR(:,2:29);
% ch_names=ch_names(2:29);
% ch_names=strrep(ch_names,'Fpz','Oz');
% 
% 
% %count the channels used
% dsizeR=size(dR);
% 
% ArrayOneEventR=[];
% ArrayOneEventConcatR=[];
%   
% for ind=1:length(StimTimeR)
%     ArrayOneEventR=dR(StimTimeR(ind)-64:StimTimeR(ind)+448,:);
%       
%     ArrayOneEventConcatR=cat(3,ArrayOneEventConcatR,ArrayOneEventR);
% end
% 
% % grand average
% AverageStimR=mean(ArrayOneEventConcatR,3);
% 
% % average of the first half of stims
% AverageStim1R=ArrayOneEventConcatR(:,:,1:floor(N/2));
% AverageStim1R=mean(AverageStim1R,3);
% % average of the second half of stims
% AverageStim2R=ArrayOneEventConcatR(:,:,round(N/2):N);
% AverageStim2R=mean(AverageStim2R,3);
% 
% % scale down with the same scaling factor as the left eye
% %MaxOfMatrix=max(max(AverageStim));
% AverageStimNR=AverageStimR/MaxOfMatrix;
% AverageStim1NR=AverageStim1R/MaxOfMatrix;
% AverageStim2NR=AverageStim2R/MaxOfMatrix;
% 
% 
% % % IF DESIRED INCREASE EEG PLOT n-FOLD
% % n=1;
% % AverageStimN=n.*AverageStimN;
% % AverageStim1N=n.*AverageStim1N;
% % AverageStim2N=n.*AverageStim2N;
% 
% % set the swaying baseline to 0
% baselinedrift=AverageStimNR(1:60,:);
% baselinedrift=mean(baselinedrift,1);
% baselinedrift=repmat(baselinedrift,513,1);
% AverageStimNR=AverageStimNR-baselinedrift;
% AverageStim1NR=AverageStim1NR-baselinedrift;
% AverageStim2NR=AverageStim2NR-baselinedrift;
% 
% % % set offset for EEG plot
% % %OffsetMatrix=[1:dsize(2)];
% % OffsetMatrix=[dsize(2):-1:1];
% % OffsetMatrix=repmat(OffsetMatrix,length(ArrayOneEventConcat),1);
% 
% 
% %AverageStim for plot
% AverageStimForPlotR=AverageStimNR+OffsetMatrix;
% AverageStim1ForPlotR=AverageStim1NR+OffsetMatrix;
% AverageStim2ForPlotR=AverageStim2NR+OffsetMatrix;
% 
% % plot averaged eeg (figure 2)
% figure;
% hold all 
% 
% plot(AverageStimForPlotR,'r','linewidth',2)
% plot(AverageStim1ForPlotR,'k')
% plot(AverageStim2ForPlotR,'k')
% 
% title(['Right eye'])
% 
% xlim([0 513])
% set(gca, 'xtick',[1:64:513])  
% set(gca, 'xtickLabel',{'-0.0625','0','0.0625','0.125','0.1875','0.25','0.3125','0.375','0.4375'})
% 
% set(gca, 'ytick',[1:1:dsize(2)])  
% 
% set(gca, 'ytickLabel',ch_names(end:-1:1))
% 
% set(gca,'FontSize',6)
% 
% xlabel('Time (s)')
% ylabel('Channels')
% ylim([-1 dsize(2)+2])
% 
% % plot vertical line to mark the stimulation
% hold on
% a=[64 64];
% b=[1 dsize(2)];
% plot(a,b,'k')   
% 
% % find the P100
% [P100ampliR P100sampleR]=min(AverageStimNR(166:197,21));
% P100sampleR=P100sampleR+166;
% P100delayR=(P100sampleR-64)/1.024;
% disp('right P100 delay is ');
% disp(P100delayR)
% 
% % brain map (figure 2)
% mapR=AverageStimNR(P100sampleR-4:P100sampleR+5,:);
% mapR=mean(mapR,1);
% mapR=[0 0 0 mapR(1) 0 mapR(12) 0 0 0; 0 mapR(23) mapR(2) mapR(6) mapR(10) mapR(17) mapR(13) mapR(24) 0;...
%     mapR(9) mapR(3) mapR(25) mapR(7) mapR(11) mapR(18) mapR(26) mapR(14) mapR(20);...
%     0 mapR(23) mapR(4) mapR(8) mapR(22) mapR(19) mapR(15) mapR(28) 0;...
%     0 0 0 mapR(5) mapR(21) mapR(16) 0 0 0];
% % map=reshape(map,9,5);
% % map=map';
% mapR=-mapR;
% figure
% imagesc(mapR)
% colorbar('location','southoutside')
% caxis([-1 1])
% title(['Right eye'])
% 
% 
% %--------------------------------------------------------------------------
% % figure overlaping left and right
% figure
% subplot(5,9,1)
% L=[0 0 0 0 0; 0 -1 0 0 0; 0 -1 0 0 0; 0 -1 0 0 0; 0 -1 0 0 0; 0 -1 0 0 0; 0 -1 -1 -1 0; 0 0 0 0 0];
% imagesc(L)
% caxis([-1 1])
% axis off
% 
% subplot(5,9,9)
% R=[0 0 0 0 0; 0 1 1 1 0; 0 1 0 1 0; 0 1 1 1 0; 0 1 1 0 0; 0 1 0 1 0;0 1 0 1 0; 0 0 0 0 0];
% imagesc(R)
% caxis([-1 1])
% axis off
% 
% subplot(5,9,4)
% plot(AverageStim(64:321,1),'b')
% hold on
% plot(AverageStimR(64:321,1),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['Fp1'])
% 
% subplot(5,9,6)
% plot(AverageStim(64:321,12),'b')
% hold on
% plot(AverageStimR(64:321,12),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['Fp2'])
% 
% subplot(5,9,11)
% plot(AverageStim(64:321,23),'b')
% hold on
% plot(AverageStimR(64:321,23),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['F9'])
% 
% subplot(5,9,12)
% plot(AverageStim(64:321,2),'b')
% hold on
% plot(AverageStimR(64:321,2),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['F7'])
% 
% subplot(5,9,13)
% plot(AverageStim(64:321,6),'b')
% hold on
% plot(AverageStimR(64:321,6),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['F3'])
% 
% subplot(5,9,14)
% plot(AverageStim(64:321,10),'b')
% hold on
% plot(AverageStimR(64:321,10),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['Fz'])
% 
% subplot(5,9,15)
% plot(AverageStim(64:321,17),'b')
% hold on
% plot(AverageStimR(64:321,17),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['F4'])
% 
% subplot(5,9,16)
% plot(AverageStim(64:321,13),'b')
% hold on
% plot(AverageStimR(64:321,13),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['F8'])
% 
% subplot(5,9,17)
% plot(AverageStim(64:321,24),'b')
% hold on
% plot(AverageStimR(64:321,24),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['F10'])
% 
% subplot(5,9,19)
% plot(AverageStim(64:321,9),'b')
% hold on
% plot(AverageStimR(64:321,9),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['T9'])
% 
% subplot(5,9,20)
% plot(AverageStim(64:321,3),'b')
% hold on
% plot(AverageStimR(64:321,3),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['T7'])
% 
% subplot(5,9,21)
% plot(AverageStim(64:321,25),'b')
% hold on
% plot(AverageStimR(64:321,25),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['C5'])
% 
% subplot(5,9,22)
% plot(AverageStim(64:321,7),'b')
% hold on
% plot(AverageStimR(64:321,7),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['C3'])
% 
% subplot(5,9,23)
% plot(AverageStim(64:321,11),'b')
% hold on
% plot(AverageStimR(64:321,11),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['Cz'])
% 
% subplot(5,9,24)
% plot(AverageStim(64:321,18),'b')
% hold on
% plot(AverageStimR(64:321,18),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['C4'])
% 
% subplot(5,9,25)
% plot(AverageStim(64:321,26),'b')
% hold on
% plot(AverageStimR(64:321,26),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['C6'])
% 
% subplot(5,9,26)
% plot(AverageStim(64:321,14),'b')
% hold on
% plot(AverageStimR(64:321,14),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['T8'])
% 
% subplot(5,9,27)
% plot(AverageStim(64:321,20),'b')
% hold on
% plot(AverageStimR(64:321,20),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['T10'])
% 
% subplot(5,9,29)
% plot(AverageStim(64:321,23),'b')
% hold on
% plot(AverageStimR(64:321,23),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['P9'])
% 
% subplot(5,9,30)
% plot(AverageStim(64:321,4),'b')
% hold on
% plot(AverageStimR(64:321,4),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['P7'])
% 
% subplot(5,9,31)
% plot(AverageStim(64:321,8),'b')
% hold on
% plot(AverageStimR(64:321,8),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['P3'])
% 
% subplot(5,9,32)
% plot(AverageStim(64:321,22),'b')
% hold on
% plot(AverageStimR(64:321,22),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['Pz'])
% 
% subplot(5,9,33)
% plot(AverageStim(64:321,19),'b')
% hold on
% plot(AverageStimR(64:321,19),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['P4'])
% 
% subplot(5,9,34)
% plot(AverageStim(64:321,15),'b')
% hold on
% plot(AverageStimR(64:321,15),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['P8'])
% 
% subplot(5,9,35)
% plot(AverageStim(64:321,28),'b')
% hold on
% plot(AverageStimR(64:321,28),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['P10'])
% 
% subplot(5,9,40)
% plot(AverageStim(64:321,5),'b')
% hold on
% plot(AverageStimR(64:321,5),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['O1'])
% 
% subplot(5,9,41)
% plot(AverageStim(64:321,21),'b')
% hold on
% plot(AverageStimR(64:321,21),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['Oz'])
% 
% subplot(5,9,42)
% plot(AverageStim(64:321,16),'b')
% hold on
% plot(AverageStimR(64:321,16),'r')
% set(gca, 'xtick',[1:64:256])
% xlim([0 258])
% set(gca, 'xtickLabel',{'0','0.0625','0.125','0.1875','0.25'})
% set(gca,'FontSize',6)
% ylim([-15 +10])
% title(['O2'])