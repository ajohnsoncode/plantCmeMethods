function trackingMovie_dualChan

% the cleaned tracks are ploted onto the movie to show the tracks included
% in the analysis.  Red circles indicate the track at the current frame
% and the blue lines represent the track pervious to the current frame.
% 
% The output is a image sequence, which you can combine in imageJ to make a
% movie
%
% AJ 28/07/2018

%%
[movieFile,moviePath] = uigetfile('*.tif','Select the Chan1 movie file');
cd(moviePath)
movie1 = tiffread(movieFile);
[movieFile,moviePath] = uigetfile('*.tif','Select the Chan2 movie file');
cd(moviePath)
movie2 = tiffread(movieFile);

[trkFile,trkFolder] = uigetfile('*.mat','Select the clean tracking');
cd(trkFolder)
load(trkFile);

cd(moviePath)
mkdir('Tracking_Frames')
cd('Tracking_Frames')

% add a colour to each track
for i = 1:size(tracks,2)
    tracks(i).colour = rand(1,3);
end

% plot
figure;
set(gca,'LooseInset',get(gca,'TightInset'))

b = zeros(size(movie1(1).data));

for i = 1:size(movie1,2)
    img(:,:,1) = movie1(i).data *5;
    img(:,:,2) = movie2(i).data *5;
    img(:,:,3) = b;
    imshow(img)
    hold on
    for n = 1:size(tracks,2)
        [toPlot,row] = ismember(i,tracks(n).f);
        if toPlot == 1
%            plot(tracks(n).x(row),tracks(n).y(row),'or','markers',5)
           plot(tracks(n).x(1:row),tracks(n).y(1:row),'color',tracks(n).colour)
        end
    end
    hold off
    name = [movieFile(1:end-4),'_',num2str(i,'%03d'),'.tif'];
    disp(['Writing frame ',name])
    frame = frame2im(getframe(gca));
    imwrite(frame,name)
end
