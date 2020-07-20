function meanProfile_singChan(cellInfo)

% Plots the normalized fluorescent profile of tracks which have the mean
% lifetime (+/- 3 frames).
%
% AJ (last mod 20/07/2020)

%% load the time info
frameGap = cellInfo.frameGap;

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
meanRange = meanLifetime-(3*xFactor):xFactor:meanLifetime+(3*xFactor);

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
    if numel(x(i).A(1,:))*xFactor == x(i).lifetime_s
        x(i).toKeep = 1;
    else
        x(i).toKeep = 0;
    end
end
x = x([x.toKeep] == 1);

% combines and pads profiles for departure
rangeMax = max(meanRange);

for i = 1:size(x,2)
    if (size(x(i).A(1,:),2)*xFactor) == rangeMax
        Chan1(i,:) = x(i).A(1,:);
    else
        padSize = round((rangeMax - ((size(x(i).A,2) * xFactor)))/xFactor);
        Chan1(i,:) = padarray(x(i).A(1,:),[0 padSize],NaN,'pre');
    end
end

% normalise each track

for i = 1:size(Chan1,1)
    red = Chan1(i,:);
    Chan1Max = max(red);
    Chan1Min = min(red);
    Chan1Norm(i,:) = (red - Chan1Min) / (Chan1Max-Chan1Min);
end

Chan1Mean = nanmean(Chan1Norm);
Chan1SD = nanstd(Chan1Norm);
Chan1SEM = Chan1SD / sqrt(size(Chan1Norm,1));

%% Plot
timeLine = (-numel(Chan1Mean))+1:1:0;
figure
errorbar(timeLine,Chan1Mean,Chan1SEM,'r')
hold
xlabel({'Time (s)'});
ylabel({'Norm. Fluro (AU).'});

saveas(gcf,[cellInfo.no,'_normMeanFluro.fig'])

%% save the data
meanProfile.master = Chan1Mean;
meanProfile.masterSEM = Chan1SEM;
meanProfile.n = size(Chan1Mean,1);
meanProfile.timeLine = timeLine;

outputName = [cellInfo.no,'_meanProfile.mat'];
save(outputName,'meanProfile')
