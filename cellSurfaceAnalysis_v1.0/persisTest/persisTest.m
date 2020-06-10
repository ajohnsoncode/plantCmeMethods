function persisTest

% Uses the raw track file to detemine the number of tracks present within
% the 1st 100 frames of the movie which persist over thie range.
% Therefore, singChan_cellSurfaceAnalysis needs to be coompleted
% beforehand.Tracks are cleaned remove ones too close to the edge and too
% short.
%
% AJ 17/10/2019

%% load the raw tracking
[file,filePath] = uigetfile('*.mat','Select the raw ProcessedTracks.mat file');
cd(filePath)
load(file)

[file,path] = uigetfile('*.mat','Select the CellInfo.mat file');
cd(path)
load(file)

cd(filePath)

%% Clean Tracks (but not removing tracks at the start)
edgeBuffer = 10;
minLength = 25;

% remove tracks at edge of movie
for i = 1:size(tracks,2)
    length = (tracks(i).end - tracks(i).start) +1;
    tracks(i).trackLength = length;
end

tracks = tracks([tracks.trackLength] >= minLength);

% Cut tracks too close to the edge of the movie 

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

%%
% filter tracks which have frames within 1st 100 frames
for i = 1:size(tracks,2)
    if sum(ismember(1:100,tracks(i).f)) >= 1
        tracks(i).in1st100 = 1;
    else
        tracks(i).in1st100 = 0;
    end
end
tracksIn1st100 = tracks([tracks.in1st100] == 1);

% how many of these are present at f1
tracksAtStartOf100 = tracksIn1st100([tracksIn1st100.start] == 1);

% how many have a lifetime longer than 100
tracksPersit = tracksAtStartOf100([tracksAtStartOf100.end] >= 100);

% calculate the % of persit tracks in 1st 100 frames
percentagePersit = (size(tracksPersit,2))/(size(tracksIn1st100,2)) * 100

save('persisData.mat','tracksIn1st100','tracksAtStartOf100','tracksPersit','percentagePersit')