%%% examine performance of experimental and control animals across days
%%% assumes trialdata files have already been generated and that they have
%%% been concatenated using concatenateBehaviorData.mat

%%% NOTE ABOUT FRAME RATE ERRORS
%%% Sessions run before 171008 have frame rate error where cameras were
%%% collecting 1 frame/4.9 seconds or so --> 202.5 frames/s in the videos.
%%% Sessions run on/after 171008 have correct frame rate of 200 frames/sec


%% clean up workspace
clear all
close all

%% tell MATLAB whether I am working on the office desktop (ALBUS) or my laptop (OREK) so that it knows what directories to use
machine = 'ALBUS';
%machine = 'OREK';

%% establish directories and go to the one where I have the behavior data stored
if strcmp(machine, 'ALBUS')
    behDataDir = 'C:\olivia\data\concat beh dat';
    saveDir = 'C:\olivia\data\PCP2ChR2PilotCodeOutput';
elseif strcmp(machine, 'OREK')
    behDataDir = 'E:\data\concat beh dat';
    saveDir = 'C:\Users\kimol\Documents\data\PCP2ChR2Pilot project\matlab output';
else
    error('ERROR: please tell MATLAB what machine you are using & supply directory contingencies')
end
cd(behDataDir)

%% record of animal numbering/identity
% might be better to start storing this as an external file instead of
% taking up so many lines establishing these data here?

mice(1,1).name='OK202'; % PCP2ChR2
mice(1,1).crcrit=0.1;

mice(2,1).name='OK203'; % PCP2ChR2
mice(2,1).crcrit=0.1;

mice(3,1).name='OK204'; % PCP2ChR2
mice(3,1).crcrit=0.1;

mice(4,1).name='OK206'; % PCP2ChR2
mice(4,1).crcrit=0.1;

mice(5,1).name='OK207'; % WT
mice(5,1).crcrit=0.1;

mice(6,1).name='OK208'; % WT
mice(6,1).crcrit=0.1;

mice(7,1).name='OK209'; % WT
mice(7,1).crcrit=0.1;

mice(8,1).name='OK210'; % WT
mice(8,1).crcrit=0.1;


[hardware{1:8,1}] = deal('arduino');


%% load behavior data
load('190506_PCP2ChR2PilotExpt_allAnimBehData.mat')
load('190506_PCP2ChR2PilotExpt_timeVector.mat')

%% turn the trial data into useful data
[rbdatDayData, spontrecovdata] = getDayData_PCP2ChR2Pilot(rbdat, timeVector, mice); 

%% load the days to plot
% the spreadsheet itself should be self-explanatory. Each row lists the
% dates for a mouse's manipulation/pre-manipulation days. When the mouse
% had less than 10 days of the manipulation, there is a NaN. The headers in
% the file note which mouse/manipulation type there is.
if strcmp(machine, 'ALBUS')
    cd('C:\olivia\data\data summaries\IO inhibition extinction project\spreadsheets')
elseif strcmp(machine,'OREK')
    cd('E:\data\spreadsheets')
end
[num, txt, raw] = xlsread('PCP2ChR2ExpAndWTControl.xlsx');


%% set up the plotData organization (will wind up being in alphabetical order)
plotDataAnimals = unique(rbdat.mouse);
expMice.names = {'OK202'; 'OK203'; 'OK204'; 'OK206'};
contMice.names = {'OK207'; 'OK208'; 'OK209'; 'OK210'};

%% spontaneous recovery analysis
[spontRecDayData, mouseKey] = spontRecAndDatesIntoSummaryData(txt,...
    raw, spontrecovdata, 'unpaired extinction + laser', plotDataAnimals);

%% organize and plot summary statistic data: CR probability
[plotData.csuslaser] = trialsAndDatesIntoSummaryData(txt, raw, rbdatDayData,...
    'CS + laser + US', plotDataAnimals); 
[plotData.cslaser] = trialsAndDatesIntoSummaryData(txt, raw, rbdatDayData,...
    'CS alone extinction + laser', plotDataAnimals); 
[plotData.cslaserus] = trialsAndDatesIntoSummaryData(txt, raw, rbdatDayData, ...
    'unpaired extinction + laser', plotDataAnimals); 
[plotData.addlaser] = trialsAndDatesIntoSummaryData(txt, raw, rbdatDayData, ...
    'add 180 ms laser', plotDataAnimals); 
[plotData.unpext] = trialsAndDatesIntoSummaryData(txt, raw, rbdatDayData, ...
    'unpaired extinction', plotDataAnimals); 

%% saving the plotData structures
% save the plotData structures
%       only going to save crprob and cradjamp for now. the hit and
%       miss trial data from this function's output only uses the CR
%       criterion to determine a hit and a miss rather than the user-scored
%       data, so maybe I should get rid of these parts of the data
%       structures for the final data outputs?
cd(saveDir)
if exist('plotData_during_CRProb.xlsx','file')~=2 % only go through the trouble of writing the files if they do not already exist in the savedir
    % during data
    duringCRProbSave = concatPlotDataToCell(plotData.during.crprob.data,...
        plotData.during.mouse, 'during');
    xlswrite('plotData_during_CRProb.xlsx', duringCRProbSave)
    duringCRAmpSave = concatPlotDataToCell(plotData.during.cradjamp.data,...
        plotData.during.mouse, 'during');
    xlswrite('plotData_during_CRAdjAmp.xlsx', duringCRProbSave)
    
    % after
    afterCRProbSave = concatPlotDataToCell(plotData.after.crprob.data,...
        plotData.after.mouse, 'after');
    xlswrite('plotData_after_CRProb.xlsx', afterCRProbSave)
    afterCRAmpSave = concatPlotDataToCell(plotData.after.cradjamp.data,...
        plotData.after.mouse, 'after');
    xlswrite('plotData_after_CRAdjAmp.xlsx', afterCRProbSave)
    
    % early
    earlyCRProbSave = concatPlotDataToCell(plotData.early.crprob.data,...
        plotData.early.mouse, 'early');
    xlswrite('plotData_early_CRProb.xlsx', earlyCRProbSave)
    earlyCRAmpSave = concatPlotDataToCell(plotData.early.cradjamp.data,...
        plotData.early.mouse, 'early');
    xlswrite('plotData_early_CRAdjAmp.xlsx', earlyCRProbSave)
    
    % late
    lateCRProbSave = concatPlotDataToCell(plotData.late.crprob.data,...
        plotData.late.mouse, 'late');
    xlswrite('plotData_late_CRProb.xlsx', lateCRProbSave)
    lateCRAmpSave = concatPlotDataToCell(plotData.late.cradjamp.data,...
        plotData.late.mouse, 'late');
    xlswrite('plotData_late_CRAdjAmp.xlsx', lateCRProbSave)
    disp('SAVED plotData SPREADSHEETS')
end

% CR probability plots, median with IQR as the error bars
[during, after, late, early, handles]=plotPilotDiffManips...
    (plotData.csuslaser.crprob, plotData.cslaser.crprob, plotData.cslaserus.crprob,...
    plotData.unpext.crprob, 'CR Probability', [0 1], [0 19], 'median',...
    plotDataAnimals, expMice.names, contMice.names);

[during, after, late, early, handles]=plotPilotDiffManips...
    (plotData.csuslaser.cradjamp, plotData.cslaser.cradjamp, plotData.cslaserus.cradjamp,...
    plotData.unpext.cradjamp, 'CR AdjAmp', [0 0.7], [0 19], 'median',...
    plotDataAnimals, expMice.names, contMice.names);


%% organize and plot mean eyelid trace data

[eyelidTraceAdj.csuslaser] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData,...
    'CS + laser + US', 1);
[eyelidTraceAdj.cslaser] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData,...
    'CS alone extinction + laser', 1);
[eyelidTraceAdj.cslaserus] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData,...
    'unpaired extinction + laser', 1);
[eyelidTraceAdj.addlaser] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData,...
    'add 180 ms laser', 1);
[eyelidTraceAdj.unpext] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData,...
    'unpaired extinction', 1);

figure
hold on
for d = 1:4
avgme = [];
for i = 1:4
    avgme = [avgme; eyelidTraceAdj.addlaser.mean{i,d}];
end
plot(timeVector, mean(avgme))
pause
end
title('add laser')
legend('2 days before adding laser', '1 day before', 'laser day 1', 'laser day 2', 'Location', 'SouthOutside')
xlabel('time')
ylabel('FEC - baseline')
fig = gcf;
fig.InvertHardcopy = 'off';


figure
hold on
for d = 1:12
avgme = [];
for i = 1:4
    avgme = [avgme; eyelidTraceAdj.cslaserus.mean{i,d}];
end
plot(timeVector, mean(avgme))
pause
end
title('CS + laser, US')

figure
hold on
for d = 1:12
avgme = [];
for i = 1:4
    avgme = [avgme; eyelidTraceAdj.cslaser.mean{i,d}];
end
plot(timeVector, mean(avgme))
pause
end
title('CS + laser')



%% STOPPED EDITING FOR PCP2ChR2 here %%

% made these functions to decrease the number of lines to scroll through in
% this script
[handles, plotMe] = plotEyelidTracesFromDuringPhase(eyelidTraceAdj, expMice, contMice, expMice.duringDays,...
    contMice.duringDays, timeVector, 'median', 'during',...
    {'baseline', 'laser 1', 'laser 3', 'last laser'});
figure(handles.during)
savefig('eyeTrc_during.fig')
print('eyeTrc_during.jpeg', '-djpeg')
figure(handles.duringNorm)
savefig('eyeTrc_duringNorm.fig')
print('eyeTrc_duringNorm.jpeg', '-djpeg')
figure(handles.duringHit)
savefig('eyeTrc_duringHit.fig')
print('eyeTrc_duringHit.jpeg', '-djpeg')
close all

%plotEyelidTracesFromDuringPhase(eyelidTraceAdj, expMice, contMice, expMice.duringDays, contMice.duringDays, timeVector, 'median', 'during', {'baseline', 'laser 1', 'laser 3', 'last laser'}) % the mean plots look a lot better
[handles, plotMe] = plotEyelidTracesFromDuringPhase(eyelidTraceAdj, expMice, contMice, expMice.reacqDays, ...
    contMice.reacqDays, timeVector, 'median', 'reacq',...
    {'last laser', 'reacq 1', 'reacq 2', 'last'});
figure(handles.during)
savefig('eyeTrc_savings.fig')
print('eyeTrc_savings.jpeg', '-djpeg')
figure(handles.duringNorm)
savefig('eyeTrc_savingsNorm.fig')
print('eyeTrc_savingsNorm.jpeg', '-djpeg')
figure(handles.duringHit)
savefig('eyeTrc_savingsHit.fig')
print('eyeTrc_savingsHit.jpeg', '-djpeg')
close all

[handles, plotMe] = plotEyelidTracesFromEarlyPhase(eyelidTraceAdj, expMice, contMice, expMice.earlyDays, ...
    contMice.earlyDays, timeVector, 'median', 'early',...
    {'baseline', 'laser 1', 'laser 3', 'last'});
figure(handles.early)
savefig('eyeTrc_early.fig')
print('eyeTrc_early.jpeg', '-djpeg')
figure(handles.earlyNorm)
savefig('eyeTrc_earlyNorm.fig')
print('eyeTrc_earlyNorm.jpeg', '-djpeg')
figure(handles.earlyHit)
savefig('eyeTrc_earlyHit.fig')
print('eyeTrc_earlyHit.jpeg', '-djpeg')
close all

[earlytracevals, latetracevals] = earlyEyetraceAnalysis(eyelidTrace.early.mean, eyelidTrace.early.mouse, expMice.names(1:4,:), ...
    expMice.earlyDays(1:4,:));
quantileBoxScatterDotCon__jitter(earlytracevals(:,1), earlytracevals(:,2), ...
    'baseline', 'laserDay1', 'FEC',...
    ['max FEC 40-70 ms after CS onset; p = ', num2str(ranksum(earlytracevals(:,1), earlytracevals(:,2)))], 0)
ylim([0 1])
xlim([0.5 2.5])
set(gca, 'XTickLabels', {'','Baseline','','Laser Day 1',''})

quantileBoxScatterDotCon__jitter(latetracevals(:,1), latetracevals(:,4), ...
    'baseline', 'laserDay1', 'FEC',...
    ['max FEC 150-200 ms after CS onset; p = ', num2str(ranksum(latetracevals(:,1), latetracevals(:,4)))], 0)
ylim([0 1])
xlim([0.5 2.5])
set(gca, 'XTickLabels', {'','Baseline','','Last Laser Day',''})


[handles, plotMe] = plotEyelidTracesFromEarlyPhase(eyelidTraceAdj, expMice, contMice, expMice.earlyReacqDays, ...
    contMice.earlyReacqDays, timeVector, 'mean', 'early reacq',...
    {'last laser', 'reacq 1', 'reacq 3', 'last'});
figure(handles.early)
savefig('eyeTrc_earlyReacq.fig')
print('eyeTrc_earlyReacq.jpeg', '-djpeg')
figure(handles.earlyNorm)
savefig('eyeTrc_earlyReacqNorm.fig')
print('eyeTrc_earlyReacqNorm.jpeg', '-djpeg')
figure(handles.earlyHit)
savefig('eyeTrc_earlyReacqHit.fig')
print('eyeTrc_earlyReacqHit.jpeg', '-djpeg')
close all

[handles, plotMe] = plotEyelidTracesFromAfterPhase(eyelidTraceAdj, expMice, expMice.afterDays, ...
    timeVector, 'median', 'after',...
    {'baseline', 'laser 1', 'laser 3', 'last'});
figure(handles.after)
savefig('eyeTrc_after.fig')
print('eyeTrc_after.jpeg', '-djpeg')
figure(handles.afterNorm)
savefig('eyeTrc_afterNorm.fig')
print('eyeTrc_afterNorm.jpeg', '-djpeg')
figure(handles.afterHit)
savefig('eyeTrc_afterHit.fig')
print('eyeTrc_afterHit.jpeg', '-djpeg')
close all

[handles] = plotEyelidTracesFromLatePhase(eyelidTraceAdj, expMice, expMice.afterDays, ...
    timeVector, 'mean', 'late',...
    {'baseline', 'laser 1', 'laser 3', 'last'});
figure(handles.late)
savefig('eyeTrc_late.fig')
print('eyeTrc_late.jpeg', '-djpeg')
figure(handles.lateNorm)
savefig('eyeTrc_lateNorm.fig')
print('eyeTrc_lateNorm.jpeg', '-djpeg')
figure(handles.lateHit)
savefig('eyeTrc_lateHit.fig')
print('eyeTrc_lateHit.jpeg', '-djpeg')
close all


%%% STOPPED EDITING FOR PCP2CHR2 HERE %%%


%% STATS
colheaders = {'Group', 'Phase', 'Data' 'Comparison Type', 'p', 'T or F', 'df'};
mainFXOutput = {};
mrow = 1;

%% CRPROB
% experimental group during manipulation
idx = getIdxFromNames(expMice.names, plotDataAnimals);
expgrpdata = plotData.during.crprob.data(find(idx),:);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 8;...
    2, 3, 4, 5, 6, 7, 11;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 11];
[mainFXOutput, mrow] = runNonparametricANOVAS(expgrpdata(:,1:12), mainFXOutput, mrow,...
    'During', 'CRProb', 'Exp', friedmanIdx);

% control group during manipulation
idx = getIdxFromNames(contMice.names, plotDataAnimals);
contgrpdata = plotData.during.crprob.data(find(idx),:);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12];
[mainFXOutput, mrow] = runNonparametricANOVAS(contgrpdata(:,1:12), mainFXOutput, mrow,...
    'During', 'CRProb', 'Cont', friedmanIdx);

% experimental group reacquisition following during phase
reacqdata = [...
    expgrpdata(1,12), expgrpdata(1,13:18);...
    expgrpdata(2,8), expgrpdata(2,13:18);...
    expgrpdata(3,11), expgrpdata(3,13:18);...
    expgrpdata(4,12), expgrpdata(4,13:18);...
    expgrpdata(5,12), expgrpdata(5,13:18);...
    expgrpdata(6,11), expgrpdata(6,13:18)];
friedmanIdx = [...
    1, 2, 3, 7;...
    1, 2, 3, 7;...
    1, 2, 3, 7;...
    1, 2, 3, 7;...
    1, 2, 3, 6;...
    1, 2, 3, 4];
[mainFXOutput, mrow] = runNonparametricANOVAS(reacqdata, mainFXOutput, mrow,...
    'Reacq During', 'CRProb', 'Exp', friedmanIdx);

% experimental group after laser manipulation
idx = getIdxFromNames(expMice.names(1:4), plotDataAnimals); % only the first 4 mice went through the experiment
expgrpdata = plotData.after.crprob.data(find(idx),:);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 8;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 11];
[mainFXOutput, mrow] = runNonparametricANOVAS(expgrpdata(:,1:12), mainFXOutput, mrow,...
    'After', 'CRProb', 'Exp', friedmanIdx);

% experimental group early laser manipulation
expgrpdata = plotData.early.crprob.data(find(idx),:);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 10;...
    2, 3, 4, 5, 6, 7, 12];
[mainFXOutput, mrow] = runNonparametricANOVAS(expgrpdata(:,1:12), mainFXOutput, mrow,...
    'Early', 'CRProb', 'Exp', friedmanIdx);

%% CRADJAMP
% experimental group during manipulation
idx = getIdxFromNames(expMice.names, plotDataAnimals);
expgrpdata = plotData.during.cradjamp.data(find(idx),:);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 8;...
    2, 3, 4, 5, 6, 7, 11;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 11];
[mainFXOutput, mrow] = runNonparametricANOVAS(expgrpdata(:,1:12), mainFXOutput, mrow,...
    'During', 'CRAdjAmp', 'Exp', friedmanIdx);

% control group during manipulation
idx = getIdxFromNames(contMice.names, plotDataAnimals);
contgrpdata = plotData.during.cradjamp.data(find(idx),:);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12];
[mainFXOutput, mrow] = runNonparametricANOVAS(contgrpdata(:,1:12), mainFXOutput, mrow,...
    'During', 'CRAdjAmp', 'Cont', friedmanIdx);

% experimental group reacquisition following during phase
reacqdata = [...
    expgrpdata(1,12), expgrpdata(1,13:18);...
    expgrpdata(2,8), expgrpdata(2,13:18);...
    expgrpdata(3,11), expgrpdata(3,13:18);...
    expgrpdata(4,12), expgrpdata(4,13:18);...
    expgrpdata(5,12), expgrpdata(5,13:18);...
    expgrpdata(6,11), expgrpdata(6,13:18)];
friedmanIdx = [...
    1, 2, 3, 7;...
    1, 2, 3, 7;...
    1, 2, 3, 7;...
    1, 2, 3, 7;...
    1, 2, 3, 6;...
    1, 2, 3, 4];
[mainFXOutput, mrow] = runNonparametricANOVAS(reacqdata, mainFXOutput, mrow,...
    'Reacq During', 'CRAdjAmp', 'Exp', friedmanIdx);

% experimental group after laser manipulation
idx = getIdxFromNames(expMice.names(1:4), plotDataAnimals); % only the first 4 mice went through the experiment
expgrpdata = plotData.after.cradjamp.data(find(idx),:);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 8;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 11];
[mainFXOutput, mrow] = runNonparametricANOVAS(expgrpdata(:,1:12), mainFXOutput, mrow,...
    'After', 'CRAdjAmp', 'Exp', friedmanIdx);

% experimental group early laser manipulation
expgrpdata = plotData.early.cradjamp.data(find(idx),:);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 10;...
    2, 3, 4, 5, 6, 7, 12];
[mainFXOutput, mrow] = runNonparametricANOVAS(expgrpdata(:,1:12), mainFXOutput, mrow,...
    'Early', 'CRAdjAmp', 'Exp', friedmanIdx);

% late manipulation
idx = getIdxFromNames(expMice.names(1:4,:), plotDataAnimals);
expgrpdata = plotData.late.crprob.data(find(idx),:);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    ];
[mainFXOutput, mrow] = runNonparametricANOVAS(expgrpdata(:,1:12), mainFXOutput, mrow,...
    'Late', 'CRProb', 'Exp', friedmanIdx);

expgrpdata = plotData.late.cradjamp.data(find(idx),:);
[mainFXOutput, mrow] = runNonparametricANOVAS(expgrpdata(:,1:12), mainFXOutput, mrow,...
    'Late', 'CRAmp', 'Exp', friedmanIdx);

%% CR Latency
idx = getIdxFromNames(expMice.names(1:4), plotDataAnimals); % only the first 4 mice went through the experiment
cd(saveDir)
% experimental group early laser manipulation
expgrpdata = plotData.early.crlatency.data(find(idx),:);
friedmanIdx = [...
     3, 4, 5, 6, 7, 8,9,12;...
     3, 4, 5, 6, 7, 8,9,12;...
     3, 4, 5, 6, 7, 8,9,10;...
     3, 4, 5, 6, 7, 8,9,12];
[mainFXOutput, mrow] = runNonparametricANOVAS(expgrpdata(:,1:12), mainFXOutput, mrow,...
    'Early', 'CRLatency', 'Exp', friedmanIdx); % the Friedman does not come out significant
% need to fix the directory that the posthocs are getting saved in

%% set up output cells for ranksum comparisons
colheaders_ranksum = {'Data A', 'Data B', 'T', 'p'};
ranksumOutput = {};
rrow = 1;

%% Ranksum comparisons
% compare performance early on the first reacq session with performance
% early on the last baseline session
% CONTAINS THE COMPARISONS TO THE FIRST 20 TRIALS
idx = getIdxFromNames(expMice.names, plotDataAnimals);
firstreacqdata = plotData.during.cradjampEarly.data(find(idx),13);
expgrpdata = plotData.during.cradjamp.data(find(idx),:);
baselinedata = expgrpdata(:,2);
ranksum(baselinedata, firstreacqdata) % performance differs between the beginning of the first reacquisition day and the last baseline session
median(baselinedata)
mad(baselinedata)
median(firstreacqdata)
mad(firstreacqdata)

firstreacqdata = plotData.during.cradjampLate.data(find(idx),13);
ranksum(baselinedata, firstreacqdata) % performance does not differ by the end of the session

firstreacqdata = plotData.during.cradjampEarly.data(find(idx),13);
friedmanIdx = [...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 8;...
    2, 3, 4, 5, 6, 7, 11;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 12;...
    2, 3, 4, 5, 6, 7, 11];
[returnData] = fetchDataAtCurrentRowAndGivenColumn(plotData.during.cradjamp.data(find(idx),:), friedmanIdx);
lastLaserdata = returnData(:,end);
ranksum(lastLaserdata, firstreacqdata) % performance does not differ between the last laser day and the beginning of the first reacq day
median(lastLaserdata)
mad(lastLaserdata)



reacqdata = [...
    expgrpdata(1,12), expgrpdata(1,13:18);...
    expgrpdata(2,8), expgrpdata(2,13:18);...
    expgrpdata(3,11), expgrpdata(3,13:18);...
    expgrpdata(4,12), expgrpdata(4,13:18);...
    expgrpdata(5,12), expgrpdata(5,13:18);...
    expgrpdata(6,11), expgrpdata(6,13:18)];
friedmanIdx = [...
    1, 2, 3, 7;...
    1, 2, 3, 7;...
    1, 2, 3, 7;...
    1, 2, 3, 7;...
    1, 2, 3, 6;...
    1, 2, 3, 4];
[returnData] = fetchDataAtCurrentRowAndGivenColumn(plotData.during.cradjamp.data(find(idx),:), friedmanIdx);
orgdReacq = returnData;
ranksum(lastLaserdata, orgdReacq(:,end))

