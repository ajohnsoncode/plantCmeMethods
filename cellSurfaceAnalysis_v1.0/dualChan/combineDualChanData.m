function combineDualChanData

% Combines data from dualChan_cellSurfaceAnalysis;
% - Combines all the lifetime data in to one file
% - Combines all the clean tracks together
% - makes a mean profile using all the combined tracks
% 
% AJ 18/10/2019

%% Sort out folders and storage location

name = input('Enter the protien or condition you are combing; ','s');
frameGap = input('Enter the frame rate (eg 1s, 500ms): ','s');

cd(uigetdir(pwd,'Select the folder of data you want'));
home = pwd;

noOfCells = input('Enter the number of cells you want to combine: ');

% select the folders from which you want to combine the data
for i = 1:noOfCells
    folder(i).dir = uigetdir;
end

%% Combine data
for i = 1:noOfCells
    fileName = num2str(folder(i).dir(end-2:end));
    cellPath = strcat(folder(i).dir,'/Experiment/Condition/');
    cd(cellPath)
    load([fileName,'_lifetimeData.mat']); 
    load([fileName,'_density.mat'])
    load([fileName,'_meanProfile.mat'])
    combinedLifetimeData(i).lifetimeData = lifeTimeData;
    combinedLifetimeData(i).density = meanNoOfTracksInRoiPerFrame;
    combinedLifetimeData(i).meanProfile = meanProfile;
    cellPath = strcat(folder(i).dir,'/Experiment/Condition/','cell',fileName,'_',frameGap,'/',fileName,'_red/Tracking');
    cd(cellPath)
    load('ProcessedTracks_Clean.mat'); 
    combinedTracks(i).tracks = tracks;
    clearvars -except home i folder noOfCells combinedLifetimeData name combinedTracks frameGap
end
    
% Combine all lifetime Values into one array

combinedLifetimes = [ ];
for i = 1:noOfCells
    combinedLifetimes = cat(1,combinedLifetimes,(combinedLifetimeData(i).lifetimeData.cleanLifetime_s));
end

%% Averages
combinedlifetimeMean = mean(combinedLifetimes)
combinedlifetimeSEM = std(combinedLifetimes)/sqrt(size(combinedLifetimes,1))
combinedlifetimeMedian = median(combinedLifetimes);
noOfCellsCombined = noOfCells
noOfCombinedEvents = size(combinedLifetimes,1)

%% Histogram
binRange = 1:1:120; 
histoPlotRange = 1:1:120;

combinedLifetimeHisto = histc(combinedLifetimes,binRange);
lifetimeHistoNorm = (combinedLifetimeHisto/sum(combinedLifetimeHisto));

figure
hisTitle = [name,' - Normalised Hisogram'];
set(gcf,'numbertitle','off','name',hisTitle);
plot(histoPlotRange,lifetimeHistoNorm(1:histoPlotRange(end)))
xlabel({'Lifetime (s)'});
ylabel({'Norm. Freq.'});
line([combinedlifetimeMean-0.000000001,combinedlifetimeMean],ylim,'Color','red','LineStyle','--')

cF = (cumsum(combinedLifetimeHisto)/sum(combinedLifetimeHisto)*100);

%% Tracks 
allTracks = [ ];
for i = 1:noOfCells
    allTracks = [allTracks,combinedTracks(i).tracks];
end

cd(home)
outputName = [name,'_allTracks.mat'];
save(outputName,'allTracks')

%% Save the output
outputName = [name,'_combinedLifetimeData.mat'];

combinedLifeTimeData.rawData = combinedLifetimeData;
combinedLifeTimeData.mean = combinedlifetimeMean;
combinedLifeTimeData.SEM = combinedlifetimeSEM;
combinedLifeTimeData.n = noOfCombinedEvents;
combinedLifeTimeData.median = combinedlifetimeMedian;
combinedLifeTimeData.rawHisto = combinedLifetimeHisto;
combinedLifeTimeData.normHisto = lifetimeHistoNorm;
combinedLifeTimeData.cumFreq = cF;

save(outputName,'combinedLifeTimeData');
outputName = [name,'_combinedLifetimeData.fig'];
saveas(gcf,outputName);

%% meanProfile
if frameGap(end-1) == 'm'
    xFactor = frameGap(1:end-2);
    xFactor = str2num(xFactor);
    if numel(num2str(xFactor)) == 3
        xFactor = xFactor/1000;
    end
else
    xFactor = frameGap(1:end-1);
    xFactor = str2num(xFactor);
end

% mean
meanLifetime = combinedlifetimeMean;

% test which frame is closest to mean 
findFrameNoRange = 0:xFactor:meanLifetime+xFactor;
a = abs(meanLifetime - findFrameNoRange(end-1));
b = abs(meanLifetime - findFrameNoRange(end));

if a < b
    meanLifetime = findFrameNoRange(end-1);
elseif b < a
    meanLifetime = findFrameNoRange(end);
end

% mean range
meanRange = meanLifetime-(3*xFactor):xFactor:meanLifetime+(3*xFactor);

for i = 1:size(allTracks,2)
    if sum(ismember(meanRange,allTracks(i).lifetime_s)) >= 1
        allTracks(i).toKeep = 1;
    else
        allTracks(i).toKeep = 0;
    end
end

x = allTracks([allTracks.toKeep] == 1);

% clean tracks with GEs
for i = 1:size(x,2)
    if numel(x(i).A(1,:)) * xFactor == x(i).lifetime_s
        x(i).toKeep = 1;
    else
        x(i).toKeep = 0;
    end
end
x = x([x.toKeep] == 1);

% combines and pads profiles for departure
rangeMax = max(meanRange);

for i = 1:size(x,2)
    if size(x(i).A(1,:),2) == rangeMax /xFactor
        Chan1(i,:) = x(i).A(1,:);
        Chan2(i,:) = x(i).A(2,:);
    else
        padSize = (rangeMax - x(i).lifetime_s) / xFactor;
        Chan1(i,:) = padarray(x(i).A(1,:),[0 padSize],NaN,'pre');
        Chan2(i,:) = padarray(x(i).A(2,:),[0 padSize],NaN,'pre');
    end
end

% normalise each track
for i = 1:size(Chan1,1)
    red = Chan1(i,:);
    Chan1Max = max(red);
    Chan1Min = min(red);
    Chan1Norm(i,:) = (red - Chan1Min) / (Chan1Max-Chan1Min);
    green = Chan2(i,:);
    Chan2Max = max(green);
    Chan2Min = min(green);
    Chan2Norm(i,:) = (green - Chan2Min) / (Chan2Max-Chan2Min);
end

Chan1Mean = nanmean(Chan1Norm);
Chan1SD = nanstd(Chan1Norm);
Chan1SEM = Chan1SD / sqrt(size(Chan1Norm,1));
Chan2Mean = nanmean(Chan2Norm);
Chan2SD = nanstd(Chan2Norm);
Chan2SEM = Chan2SD / sqrt(size(Chan2Norm,1));

% Plot
timeLine = (-numel(Chan1Mean))+1:1:0;
figure
errorbar(timeLine,Chan1Mean,Chan1SEM,'r')
hold
errorbar(timeLine,Chan2Mean,Chan2SEM,'g')
xlabel({'Time (s)'});
ylabel({'Norm. Fluro (AU).'});

outputName = [name,'_meanProfile.fig'];
saveas(gcf,outputName)

% save the data
meanProfileCombined.master = Chan1Mean;
meanProfileCombined.masterSEM = Chan1SEM;
meanProfileCombined.slave = Chan2Mean;
meanProfileCombined.slaveSEM = Chan2SEM;
meanProfileCombined.n = size(Chan1,1);
meanProfileCombined.timeLine = timeLine;

outputName = [name,'_meanProfile.mat'];
save(outputName,'meanProfileCombined')
