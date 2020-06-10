function dualChan_cellSurfaceAnalysis
% 
% Lifetime analysis for dual channel movies.  Uses a modified version of
% the cmeAnalysis package to detect and track the objects.  It uses the
% master/slave method. Tracks are then cleaned to removed tracks which are
% too short, too close to the edges of the movie and too close to the start
% of end of the movie.
%
% To use;
% - Input the frame rate at which the movie was captured (use either
% seconds of milliseconds)
% - Select the master channel
% - Select the slave channel
% - follow the onscreen prompts to enter information
% 
% The data saved includes the detections, raw tracking, cleaned tracks,
% lifetime data, spot density, mean fluorescent profile, ratio between the
% lifetimes of the two channels and the difference in lifetimes between the
% two channels.
%
%
% AJ Mod (17/10/2019)

%% Prepare the data 
% Input the time inbetween frames
frameGap = input('Enter the time between frames (e.g., 500ms, 1s): ','s');

% Select the two channel movies
[chan1File,filePath] = uigetfile('*.tif','Select the Chan1 movie');
cd(filePath)
[chan2File,~] = uigetfile('*.tif','Select the Chan2 movie');

% make folder layout
cellNo = chan1File(1:3);
mkdir(cellNo)

homeFolder = strcat(filePath,cellNo);
experimentFolder = strcat(homeFolder,'/Experiment');
mkdir(experimentFolder)
conditionFolder = strcat(experimentFolder,'/Condition');
mkdir(conditionFolder)
cellFolder = strcat(conditionFolder,'/cell',cellNo,'_',frameGap);
mkdir(cellFolder)

% Cut the tif stack into frames and puts them in folders
movefile(chan1File,cellFolder)
movefile(chan2File,cellFolder)
stk2tiffDirs(cellFolder)
cd(conditionFolder)

% save all the useful info
cellInfo.no = cellNo;
cellInfo.chan1 = chan1File;
cellInfo.chan2 = chan2File;
cellInfo.frameGap = frameGap;
cellInfo.location = homeFolder;
cellInfo.conditionFolder = conditionFolder;
cellInfo.cellFolder = cellFolder;
cellInfo.trackingFolder = strcat(cellFolder,'/',(chan1File(1:end-4)),'/Tracking');
cellInfo.trackingFile = strcat(cellInfo.trackingFolder,'/ProcessedTracks.mat');

%% Run modified cmePack
cmeAnalysisTrackingAndDetection_dualChan

%% Load the movie
cd(cellInfo.cellFolder)
movie = tiffread(cellInfo.chan1);
cd(cellInfo.conditionFolder)
cellInfo.xSize = movie(1).width;
cellInfo.ySize = movie(1).height;
cellInfo.noOfFrames = size(movie,2);

%% cleanUp
cleanUp_dualChan(cellInfo)
cellInfo.cleanTrackingFile = strcat(cellInfo.trackingFolder,'/ProcessedTracks_Clean.mat');

%% Lifetime
cmeLifetimes_dualChan(cellInfo)

%% Density
trackDensity_dualChan(cellInfo)

%% F Profile
meanProfile_DualChan(cellInfo)

%% Save cellInfo
save('cellInfo.mat','cellInfo')