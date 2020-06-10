function cmeLifetimes_dualChan(cellInfo)

% Calculates the lifetimes of cleaned cmeAnalysis tracks and saves the output.
%
% AJ 10/11/2017

clc

%% Select and Load the tracks and other Info
load(cellInfo.cleanTrackingFile)

%% Calculate lifetimes and stats

lifetime = [tracks.lifetime_s].';

noOfEvents = size(lifetime,1);

lifetimeMean = mean(lifetime)
lifetimeSEM = std(lifetime)/sqrt(size(lifetime,1))
noOfEvents = noOfEvents
lifetimeMedian = median(lifetime);

%% Calculate Histograms and CF

binRange = 1:1:cellInfo.noOfFrames;
histoPlotRange = 1:1:120; 

lifetimeHisto = histc(lifetime,binRange);
lifetimeHistoNorm = (lifetimeHisto/sum(lifetimeHisto));

figure
hisTitle = ['Cell _', cellInfo.no, ' - Normalised Hisogram'];
set(gcf,'numbertitle','off','name',hisTitle);
plot(histoPlotRange,lifetimeHistoNorm(1:histoPlotRange(end)))
xlabel({'Lifetime (s)'});
ylabel({'Norm. Freq.'});
line([lifetimeMean-0.000000001,lifetimeMean],ylim,'Color','red','LineStyle','--')

cF = (cumsum(lifetimeHisto)/sum(lifetimeHisto)*100);

%% Save the Data
cd(cellInfo.conditionFolder)

outputName = [cellInfo.no,'_lifetimeData.mat'];

lifeTimeData.cell = cellInfo.no;
lifeTimeData.cleanLifetime_s = lifetime;
lifeTimeData.mean = lifetimeMean;
lifeTimeData.SEM = lifetimeSEM;
lifeTimeData.median = lifetimeMedian;
lifeTimeData.n = noOfEvents;
lifeTimeData.rawHisto = lifetimeHisto;
lifeTimeData.normHisto = lifetimeHistoNorm;
lifeTimeData.cumFreq = cF;

save(outputName,'lifeTimeData')
saveas(gcf,[cellInfo.no,'_normHistogram.fig'])