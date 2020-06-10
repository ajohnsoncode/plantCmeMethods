function combineTrackingFiles_typesOfTracks
% Combines the types of tracks to make an overall histogram


%% Sort out folders and storage location
cd(uigetdir(pwd,'Select the folder of data you want'));
home = pwd;

noOfCells = input('Enter the number of cells you want to combine: ');

% select the folders from which you want to combine the data
for i = 1:noOfCells
    folder(i).dir = uigetdir;
end

%% Makes a Struct file with the Tracks

for i = 1:noOfCells
    fileName = num2str(folder(i).dir(end-2:end));
%     pathName = fileName; % change this line for the colour channel
    cellPath = strcat(folder(i).dir,'/Experiment/Condition/');
    cd(cellPath)
    load('rawCleanTracks.mat');
    load('soloTracks.mat');
    load('colocTracks.mat');
    combinedTracks(i).rawCleanTracks = rawCleanTracks;
    combinedTracks(i).soloTracks = soloTracks;
    combinedTracks(i).colocTracks = colocTracks;
    clearvars -except home i folder noOfCells combinedTracks name 
end
    
%% Combine all tracks into one array

allRawTracks = [ ];
allSoloTracks = [ ];
allColocTracks = [ ];
for i = 1:noOfCells
    allRawTracks = [allRawTracks,combinedTracks(i).rawCleanTracks];
    allSoloTracks = [allSoloTracks,combinedTracks(i).soloTracks];
    allColocTracks = [allColocTracks,combinedTracks(i).colocTracks];
end

cd(home)
save('allRawTracks.mat','allRawTracks')
save('allSoloTracks.mat','allSoloTracks')
save('allColocTracks.mat','allColocTracks')

%% work out the mean lifetime 
rawLifetimes = [allRawTracks.lifetime_s].';
meanRawLifetime = mean(rawLifetimes)
soloLifetimes = [allSoloTracks.lifetime_s].';
meanSoloLifetime = mean(soloLifetimes)
colocLifetimes = [allColocTracks.lifetime_s].';
meanColocLifetime = mean(colocLifetimes)

typeOfTracksLifetimes.rawCleanLifetimes = rawLifetimes;
typeOfTracksLifetimes.soloLifetimes = soloLifetimes;
typeOfTracksLifetimes.colocLifetimes = colocLifetimes;

binrange = 1:1:100;
rawHisto = histc(rawLifetimes,binrange);
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


