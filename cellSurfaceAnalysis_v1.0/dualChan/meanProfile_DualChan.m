function meanProfile_DualChan(cellInfo)

% Plots the normalized fluorescent profile of tracks which have the mean
% lifetime (+/- 3 frames).
%
% AJ (last mod 17/10/2019)

%% load the time info
frameGap = cellInfo.frameGap;

if frameGap(end-1) == 'm'
    xFactor = frameGap(1:end-2);
else
    xFactor = frameGap(1:end-1);
end
xFactor = str2num(xFactor);

%% load the tracking info from the cmePackage
load(cellInfo.cleanTrackingFile)

%% work out the mean
lifetime_s = [tracks.lifetime_s].';
meanLifetime = mean(lifetime_s,1);

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
meanRange = meanLifetime-3:meanLifetime+3;

for i = 1:size(tracks,2)
    if sum(ismember(meanRange,tracks(i).lifetime_s)) >= 1
        tracks(i).toKeep = 1;
    else
        tracks(i).toKeep = 0;
    end
end

x = tracks([tracks.toKeep] == 1);

% clean tracks with GEs
for i = 1:size(x,2)
    if numel(x(i).A(1,:)) == x(i).lifetime_s
        x(i).toKeep = 1;
    else
        x(i).toKeep = 0;
    end
end
x = x([x.toKeep] == 1);

% combines and pads profiles for departure
rangeMax = max(meanRange);

for i = 1:size(x,2)
    if size(x(i).A(1,:),2) == rangeMax
        Chan1(i,:) = x(i).A(1,:);
        Chan2(i,:) = x(i).A(2,:);
    else
        padSize = rangeMax - x(i).lifetime_s;
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

%% Plot
timeLine = (-numel(Chan1Mean))+1:1:0;
figure
errorbar(timeLine,Chan1Mean,Chan1SEM,'r')
hold
errorbar(timeLine,Chan2Mean,Chan2SEM,'g')
xlabel({'Time (s)'});
ylabel({'Norm. Fluro (AU).'});

saveas(gcf,[cellInfo.no,'_normMeanFluro.fig'])

%% save the data
meanProfile.master = Chan1Mean;
meanProfile.masterSEM = Chan1SEM;
meanProfile.slave = Chan2Mean;
meanProfile.slaveSEM = Chan2SEM;
meanProfile.n = size(Chan1Mean,1);
meanProfile.timeLine = -(size(Chan1Mean,1)):1:0;

outputName = [cellInfo.no,'_meanProfile.mat'];
save(outputName,'meanProfile')