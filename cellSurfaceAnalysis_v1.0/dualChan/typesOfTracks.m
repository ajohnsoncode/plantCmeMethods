function typesOfTracks

%% looks at the dual chan tracks and saves them as either, solo, coloc track 
% files. Use for individuial cellsraw red detections

%% Varibles
startBuffer = 10;
endBuffer = 10;
edgeBuffer = 10;
minLength = 5;

%% Load data

[file,path] = uigetfile('*.mat','Select the raw ProcessedTracks.mat file');
cd(path)
load(file)

[file,path] = uigetfile('*.mat','Select the cellInfo file');
cd(path)
load(file)
%% removes tracks which dont have a significant slave
for i = 1:size(tracks,2)
    if nansum(tracks(i).significantSlave) == 1 & nansum(tracks(i).significantMaster) == 1
        tracks(i).coLoc = 1;
    else
        tracks(i).coLoc = 0;
    end
end

%% cut tracks less than 5 frames long
for i = 1:size(tracks,2)
    length = (tracks(i).end - tracks(i).start) +1;
    tracks(i).trackLength = length;
end

tracks = tracks([tracks.trackLength] >= minLength);

%% Cut tracks too close to start or end of movie

tracks = tracks([tracks.start] >= startBuffer);
tracks = tracks([tracks.end] <= cellInfo.noOfFrames - endBuffer);

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

rawCleanTracks = tracks;
save('rawCleanTracks.mat','rawCleanTracks')

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
        if x(n) == x(n-1)
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
    masterLife = tracks(i).lifetime_s;
end

for i = 1:size(tracks,2)
    if tracks(i).slaveLifetime >= 5 & tracks(i).coLoc == 1
        tracks(i).toKeep = 1;
    else
        tracks(i).toKeep = 0;
    end
end

colocTracks = tracks([tracks.toKeep] == 1);
save('colocTracks.mat','colocTracks')

soloTracks = tracks([tracks.toKeep] == 0);
save('soloTracks.mat','soloTracks')
    
%% plot histos
rawCleanLifetimes = [rawCleanTracks.lifetime_s].';
soloLifetimes = [soloTracks.lifetime_s].';
colocLifetimes = [colocTracks.lifetime_s].';

typeOfTracksLifetimes.rawCleanLifetimes = rawCleanLifetimes;
typeOfTracksLifetimes.soloLifetimes = soloLifetimes;
typeOfTracksLifetimes.colocLifetimes = colocLifetimes;

binrange = 1:1:100;
rawHisto = histc(rawCleanLifetimes,binrange);
soloHisto = histc(soloLifetimes,binrange);
colocHisto = histc(colocLifetimes,binrange);

typeOfTracksLifetimes.rawHisto = rawHisto;
typeOfTracksLifetimes.soloHisto = soloHisto;
typeOfTracksLifetimes.colocHisto = colocHisto;

save('typeOfTracksLifetimes.mat','typeOfTracksLifetimes')

figure
plot(rawHisto,'k')
hold
plot(soloHisto,'r')
plot(colocHisto,'g')

saveas(gcf,'typeOfTracksLifetimes.fig')

