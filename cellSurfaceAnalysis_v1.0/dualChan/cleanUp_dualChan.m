function cleanUp_dualChan(cellInfo)

% Cleans the tracks by removing tracks which are; less than 5 frames long,
% too close to the start of end of the movie, too close to the edges of the
% movies and tracks which do not have a significant slave signal which
% lasts more than 5 frames.
%
% AJ 29/06/2018

%% 
startBuffer = 10;
endBuffer = 10;
edgeBuffer = 10;
minLength = 5;

load(cellInfo.trackingFile)

%% removes tracks which dont have a significant slave
for i = 1:size(tracks,2)
    if nansum(tracks(i).significantSlave) == 1 & nansum(tracks(i).significantMaster) == 1
        tracks(i).toKeep = 1;
    else
        tracks(i).toKeep = 0;
    end
end

tracks = tracks([tracks.toKeep] == 1);
tracks = rmfield(tracks,'toKeep');

%% Cut short tracks
for i = 1:size(tracks,2)
    length = (tracks(i).end - tracks(i).start) +1;
    tracks(i).trackLength = length;
end

tracks = tracks([tracks.trackLength] >= minLength);

%% Cut tracks too close to start or end of movie

tracks = tracks([tracks.start] >= startBuffer);
tracks = tracks([tracks.end] <= (cellInfo.noOfFrames - endBuffer));

%% Cut tracks too close to the edge of the movie 

for i = 1:size(tracks,2)
    xSmall = tracks(i).x < edgeBuffer;
    xBig = tracks(i).x > cellInfo.xSize - edgeBuffer;
    ySmall = tracks(i).y < edgeBuffer;
    yBig = tracks(i).y > cellInfo.ySize - edgeBuffer;
    xy = [xSmall,xBig,ySmall,yBig];
    xyTest = sum(sum(xy));
    if xyTest == 0 
        tracks(i).xyTest = 1;
    else
        tracks(i).xyTest = 0;
    end
end

tracks = tracks([tracks.xyTest] == 1);
tracks = rmfield(tracks,'xyTest');

%% Cut Tracks with slave lifetime less than 5 frames
frameGap = cellInfo.frameGap;

if frameGap(end-1) == 'm'
    xFactor = frameGap(1:end-2);
else
    xFactor = frameGap(1:end-1);
end
xFactor = str2num(xFactor);

for i = 1:size(tracks,2)
    x = tracks(i).significantVsBackground(2,:);
    lenmax = 1;
    len = 1;
    for n = 2:numel(x)
        if x(n) == x(n-1);
            len = len+1;
        else
            if len > lenmax
                lenmax = len;
            end
            len = 1;
        end
    end
    frameLifetime = lenmax;
    slaveLifetime = frameLifetime/xFactor;
    tracks(i).slaveLifetime = slaveLifetime;
end

tracks = tracks([tracks.slaveLifetime] >= 5* xFactor);

%% Save data
cd(cellInfo.trackingFolder)

save('ProcessedTracks_Clean.mat','tracks')
cd(cellInfo.conditionFolder)

