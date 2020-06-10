function trackDensity(cellInfo)

% The size of the ROI used to calculate the mean desnity of clean Tracks is
% 100x100.  The mean is generated from frames
% middleFrame-50:middleFrame+50.
%
% AJ 08/10/2018

%% Load the data
load(cellInfo.cleanTrackingFile)

%% find the middle of the movie
movieX = cellInfo.xSize;
movieXSize = num2str(movieX);
disp(strcat('Movie withd (x) in pixels = : ',movieXSize))
movieY = cellInfo.ySize;
movieYSize = num2str(movieY);
disp(strcat('Movie height (y) in pixels = : ',movieYSize))
middleX = movieX/2;
middleY = movieY/2;

% ROI sizes
roiSizeX = 100;
roiSizeX = roiSizeX/2;
roiSizeY = 100;
roiSizeY = roiSizeY/2;

xRange = middleX-roiSizeX:middleX+roiSizeX;
yRange = middleY-roiSizeY:middleY+roiSizeY;

% Test to see if tracks are within the roi
for i = 1:size(tracks,2)
    xSmall = tracks(i).x < xRange(1);
    xBig = tracks(i).x > xRange(end);
    ySmall = tracks(i).y < yRange(1);
    yBig = tracks(i).y > yRange(end);
    xy = [xSmall,xBig,ySmall,yBig];
    xyTest = sum(sum(xy));
    if xyTest == 0 
        tracks(i).xyTest = 1;
    else
        tracks(i).xyTest = 0;
    end
end

ROItracks = tracks([tracks.xyTest] == 1);
ROItracks = rmfield(ROItracks,'xyTest');

%% Count the tracks perframe within the ROI only tracks
noOfFrames = cellInfo.noOfFrames;

for i = 1:noOfFrames
    for j = 1:size(ROItracks,2)
        if ismember(i,ROItracks(j).f) == 1
            xx(j) = 1;
        else
            xx(j) = nan;
        end
        noOfTracksInRoi(i) = sum(~isnan(xx));
    end
end

% work out the middle frames
middleFrame = floor(noOfFrames/2);
framesToLookAt = 100;
framesToLookAt = framesToLookAt/2;
frameRange = middleFrame-framesToLookAt:middleFrame+framesToLookAt;

% mean for the middle frames
meanNoOfTracksInRoiPerFrame = mean(noOfTracksInRoi(frameRange))

%% saves data
outputName = [cellInfo.no,'_density.mat'];
save(outputName,'meanNoOfTracksInRoiPerFrame')
