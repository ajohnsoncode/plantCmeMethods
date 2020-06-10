function cleanUp(cellInfo)

% Cleans the tracks by removing tracks which are; less than 5 frames long,
% too close to the start of end of the movie, too close to the edges of the
% movies.
%
% AJ 29/06/2018

%% 
startBuffer = 10;
endBuffer = 10;
edgeBuffer = 10;
minLength = 5;

load(cellInfo.trackingFile)

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

%% Save data
cd(cellInfo.trackingFolder)

save('ProcessedTracks_Clean.mat','tracks')
cd(cellInfo.conditionFolder)

