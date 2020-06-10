function singChan_cellSurfaceAnalysis
% 
% Lifetime analysis for single channel movies.  Uses a modified version of
% the cmeAnalysis package (https://www.cell.com/developmental-cell/fulltext/S1534-5807(13)00382-1)
% to detect and track the objects.  Tracks are then
% cleaned to removed tracks which are too short, too close to the edges of
% the movie and too close to the start of end of the movie.
%
% To use; - Input the frame rate at which the movie was captured (use
% either seconds of milliseconds) - Select the master channel - follow the
% onscreen prompts to enter information
% 
% The data saved includes the detections, raw tracking, cleaned tracks,
% lifetime data, spot density and mean fluorescent profile.
%
% AJ (last mod. 17/10/2019)

%% Prepare the data 
% Input the time inbetween frames
frameGap = input('Enter the time between frames (e.g., 500ms, 1s): ','s');

% Select the two channel movies
[chan1File,filePath] = uigetfile('*.tif','Select the Chan1 movie');
cd(filePath)

% make folder layout
cellNo = chan1File(1:3);
mkdir(cellNo)

homeFolder = strcat(filePath,cellNo);
cellNo = chan1File(1:3);
experimentFolder = strcat(homeFolder,'/Experiment');
mkdir(experimentFolder)
conditionFolder = strcat(experimentFolder,'/Condition');
mkdir(conditionFolder)
cellFolder = strcat(conditionFolder,'/cell',cellNo,'_',frameGap);

% Cut the tif stack into frames and puts them in folders
movieName = strcat('cell',cellNo,'_',frameGap,'.tif');
copyfile(chan1File,movieName)
movefile(movieName,conditionFolder)
stk2tiffDirs(conditionFolder)
movefile(chan1File,cellFolder)
cd(conditionFolder)
delete(movieName)

% save all the useful info
cellInfo.no = cellNo;
cellInfo.chan1 = chan1File;
cellInfo.frameGap = frameGap;
cellInfo.location = homeFolder;
cellInfo.conditionFolder = conditionFolder;
cellInfo.cellFolder = cellFolder;
cellInfo.trackingFolder = strcat(cellFolder,'/Tracking');
cellInfo.trackingFile = strcat(cellInfo.trackingFolder,'/ProcessedTracks.mat');

%% Run modified cmePack
cmeAnalysisTrackingAndDetection

%% Load the movie
cd(cellInfo.cellFolder)
movie = tiffread(cellInfo.chan1);
cd(cellInfo.conditionFolder)
cellInfo.xSize = movie(1).width;
cellInfo.ySize = movie(1).height;
cellInfo.noOfFrames = size(movie,2);

%% cleanUp
cleanUp(cellInfo)
cellInfo.cleanTrackingFile = strcat(cellInfo.trackingFolder,'/ProcessedTracks_Clean.mat');

%% Lifetime
cmeLifetimes(cellInfo)

%% Density
trackDensity(cellInfo)

%% F Profile
meanProfile_singChan(cellInfo)

%% Save cellInfo

save('cellInfo.mat','cellInfo')

cd(cellFolder)
movefile(chan1File,homeFolder)
cd(conditionFolder)
