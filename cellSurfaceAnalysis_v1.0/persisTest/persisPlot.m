function persisPlot

% The tracks used for the persisTest are plotted on to the movie.   Red
% circles indicate the track at the current frame and the blue lines
% represent the track pervious to the current frame.
% 
% The output is a image sequence, which you can combine in imageJ to make a
% movie
%
% AJ 17/10/2019

%% Load the data
[movieFile,moviePath] = uigetfile('*.tif','Select the movie file');
cd(moviePath)
movie = tiffread(movieFile);

[trkFile,trkFolder] = uigetfile('*.mat','Select the presis Data');
cd(trkFolder)
load(trkFile);

cd(moviePath)
mkdir('Tracking_Frames_Persis')
cd('Tracking_Frames_Persis')

figure;
set(gca,'LooseInset',get(gca,'TightInset'))
for i = 1:size(movie,2)
    img = mat2gray(movie(i).data);
    imshow(img)
    hold on
    for n = 1:size(tracksAtStartOf100,2)
        [toPlot,row] = ismember(i,tracksAtStartOf100(n).f);
        if toPlot == 1
            if tracksAtStartOf100(n).end >= 100
                plot(tracksAtStartOf100(n).x(row),tracksAtStartOf100(n).y(row),'og','markers',1)
            else
                plot(tracksAtStartOf100(n).x(row),tracksAtStartOf100(n).y(row),'or','markers',1)
            end
        end
    end
    hold off
    name = [movieFile(1:end-4),'_',num2str(i,'%03d'),'.tif'];
    disp(['Writing frame ',name])
    frame = frame2im(getframe(gca));
    imwrite(frame,name)
end
