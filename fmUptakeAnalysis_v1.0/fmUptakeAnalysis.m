function fmUptakeAnalysis

% Segments single cells of an FM image based on a user entered luminance
% threshold value.  This value is entered in the GUI, and a preview of the
% segmentation of the PM signal is shown.  Once a good segmentation
% threshold is chosen, click on the white intra cellular segmented regions
% and press enter.  A mean ratio of the PM and intra cellular signal will
% be determined from all the cells selected.
% 
% AJ 14/10/2019

%% Loads the GUI for the image segmentation
uiwait(fmGUI)

load('imageData.mat')

%% Select the cells you want to include in the analysis
BW2 = bwselect(imageData.imageFilled);
imshow(BW2)
stats = regionprops(BW2,'PixelList','PixelIdxList','Centroid');

% convert raw image
% rawImage = rgb2gray(imageData.image);
rawImage = (imageData.image);

% loop for number of cells selected
for i = 1:size(stats,1)
    mask = zeros(size(imageData.imageBin,1),size(imageData.imageBin,2));
    pixels = stats(i).PixelIdxList;
    mask(pixels) = 1;
    insideCellMask = uint8(mask);
    insideCellImage = rawImage .* insideCellMask;
    
    cellWithMembrane = imdilate(mask, true(15));
    cellWithMembraneMask = uint8(cellWithMembrane);
    cellWithMembraneImage = rawImage .* cellWithMembraneMask;
    
    membrane = cellWithMembrane - mask;
    membraneMask = uint8(membrane);
    membraneImage = rawImage .* membraneMask;
    
    data(i).wholeCell = cellWithMembraneImage;
    data(i).insideCell = insideCellImage;
    data(i).membrane = membraneImage;
    data(i).centroid = stats(i).Centroid;
    data(i).insideSignal = sum(sum(insideCellImage));
    data(i).membraneSignal = sum(sum(membraneImage));
    data(i).insideOverMembraneRatio = data(i).insideSignal ./ data(i).membraneSignal;
    data(i).wholeCellMask = cellWithMembraneMask;
    data(i).insideCellMask = mask;
    data(i).membraneMask = membraneMask;
end

%% Overall Result
insideOverMembraneRatio = [data.insideOverMembraneRatio].';
averageRatio = mean(insideOverMembraneRatio)
SEM = std(insideOverMembraneRatio)/sqrt(size(data,2))
n = size(data,2)

%% Save data
[outFile,outPath] = uiputfile('*.mat','Where to save the file');
cd(outPath)
save(outFile,'data','imageData','BW2','averageRatio','SEM','n')

