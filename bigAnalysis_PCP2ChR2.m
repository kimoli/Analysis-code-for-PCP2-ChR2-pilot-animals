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
load('190520_PCP2ChR2PilotExpt_allAnimBehData.mat')
load('190520_PCP2ChR2PilotExpt_timeVector.mat')

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

%% get trial by trial data
startlewin = 44:48; % 20 to 40 ms
slrwin = 49:53; % 45 ms to 65 ms
for t = 1:length(rbdat.tDay)
    if rbdat.c_csdur(t,1)>0
        rbdat.startleamp(t,1) = max(rbdat.eyelidpos(t, startlewin)) - rbdat.baseline(t,1);
        rbdat.slramp(t,1) = max(rbdat.eyelidpos(t, slrwin)) - rbdat.baseline(t,1);
        rbdat.FEC180(t,1) = rbdat.eyelidpos(t,76) - rbdat.baseline(t,1);
        rbdat.FEC230(t,1) = rbdat.eyelidpos(t,86) - rbdat.baseline(t,1);
    else
        rbdat.startleamp(t,1) = NaN;
        rbdat.slramp(t,1) = NaN;
        rbdat.FEC180(t,1) = NaN;
        rbdat.FEC230(t,1) = NaN;
    end
    
    % define different rb baseline conditions depending on whether there
    % was a CS on this trial
    if rbdat.laserDur(t,1)>0
        lasend = (rbdat.laserDel(t,1)./5) + (rbdat.laserDur(t,1)./5) + 40; % account for 200 ms baseline once
        rbwin = lasend:(lasend+100);% the 500 ms after the laser ends
        if rbdat.c_csdur(t,1) > 0
            rbblwin = lasend-10:lasend; % the 50 ms before the laser ends as rb baseline
        elseif rbdat.c_csdur(t,1) == 0
            rbblwin = 1:40;
        end
        rbdat.rbamp(t,1) = max(rbdat.eyelidpos(t, rbwin)) - mean(rbdat.eyelidpos(t,rbblwin));
    else
        rbdat.rbamp(t,1) = NaN;
    end
end

%% get day by day data
% RB probability
% CR probability
% FEC180
% FEC230
rbdatDayData.mouse = {};
rbdatDayData.date = [];
rbdatDayData.CRProb = [];
rbdatDayData.RBProb = [];
rbdatDayData.FEC180 = [];
rbdatDayData.FEC230 = [];
rbdatDayData.RBAmp = [];
rbdatDayData.SLRAmp = [];
csidx = rbdat.c_csdur>0;
lasidx = rbdat.laserDur>0;
for m = 1:length(mice)
    thisMouseIdx = strcmpi(rbdat.mouse,mice(m,1).name);
    days = unique(rbdat.date(thisMouseIdx,1));
    for d = 1:length(days)
        thisDayIdx = rbdat.date == days(d,1);
        if sum(thisDayIdx & thisMouseIdx & lasidx) > 0
            % there are laser trials this day, so populate the rebound vals
            rbvals = rbdat.rbamp(thisDayIdx & thisMouseIdx & lasidx,1);
            numtrials = length(rbvals);
            rbprob = sum(rbvals > 0.1)./numtrials;
        else
            % there are no laser trials this day, so do not populate the
            % rebound vals
            rbvals = nan;
            rbprob = nan;
        end
        fec180vals = rbdat.FEC180(thisDayIdx & thisMouseIdx & csidx,1);
        fec230vals = rbdat.FEC230(thisDayIdx & thisMouseIdx & csidx,1);
        numtrials = length(fec180vals);
        crprob = sum(fec180vals > 0.1)./numtrials; 
        
        slrvals = rbdat.slramp(thisDayIdx & thisMouseIdx & csidx,1);
        
        
        rbdatDayData.mouse = [rbdatDayData.mouse; mice(m,1).name];
        rbdatDayData.date = [rbdatDayData.date; days(d,1)];
        rbdatDayData.CRProb = [rbdatDayData.CRProb; crprob];
        rbdatDayData.RBProb = [rbdatDayData.RBProb; rbprob];
        rbdatDayData.RBAmp = [rbdatDayData.RBAmp; nanmean(rbvals)];
        rbdatDayData.FEC180 = [rbdatDayData.FEC180; nanmean(fec180vals)];
        rbdatDayData.FEC230 = [rbdatDayData.FEC230; nanmean(fec230vals)];
        rbdatDayData.SLRAmp = [rbdatDayData.SLRAmp; nanmean(slrvals)];
                
        clear fec180vals fec230vals numtrials crprob rbvals rbprob slrvals
    end
end

cd(saveDir)

%% plot individual mice individual trial responses: CS + laser + US
[output] = trialsAndDatesIntoSummaryData_individTrials_PCP2ChR2(txt,...
    raw, rbdat, 'CS + laser + US', plotDataAnimals);

plotIndividAnimVals_PCP2ChR2(output, 'OK202', 'OK202: CS + laser + US', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK202_CSLaserUS.fig')
saveas(gcf,'OK202_CSLaserUS','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK203', 'OK203: CS + laser + US', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.8])
savefig('OK203_CSLaserUS.fig')
saveas(gcf,'OK203_CSLaserUS','png')
close(gcf)

[rows cols] = size(output.eyelidpos.data);
for r = 1:rows
    figure
    a = subplot(2,1,1);
    hold on
    b = subplot(2,1,2);
    hold on
    colorvals = [];
    colorvals_raw = [];
    for c = 1:cols
        plot(a, 1:340, output.eyelidpos.data{r,c})
        plot(b, 1:340, output.eyelidposraw.data{r,c})
        colorvals_raw = [colorvals_raw;output.eyelidposraw.data{r,c}];
        colorvals = [colorvals;output.eyelidpos.data{r,c}];
    end
    legend(b, 'b1', 'b2', '1','2','3','4','5','6','7','8','9','10','Location','EastOutside')
    legend(a, 'b1', 'b2', '1','2','3','4','5','6','7','8','9','10','Location','EastOutside')
    if r == 1
        mouse = 'OK202'; 
    else
        mouse = 'OK203';
    end
    title(a, [mouse, ': mean eyelidtrace across CS+laser+US days, adj'])
    title(b, [mouse, ': mean eyelidtrace across CS+laser+US days, raw'])
    ylim(b, [0 1])
    ylim(a, [0 1])
    savefig([mouse, '_CSlaserUS_CStraces.fig'])
    saveas(gcf,[mouse,'_CSlaserUS_CStraces'],'png')
    close(gcf)
    
    figure
    subplot(1,2,1)
    imagesc(colorvals_raw(:,1:200))
    title([mouse, ': raw mean eyetrace on CS + laser + US days'])
    hold on
    plot([86 86],[0.5 14.5], 'Color', [1 1 1], 'LineStyle', ':')
    plot([40 40],[0.5 14.5], 'Color', [1 1 1], 'LineStyle', ':')
    xlabel('bin')
    ylabel('Day')
    subplot(1,2,2)
    imagesc(colorvals(:,1:200))
    title([mouse, ': adjusted mean eyetrace on CS + laser + US days'])
    hold on
    plot([86 86],[0.5 14.5], 'Color', [1 1 1], 'LineStyle', ':')
    plot([40 40],[0.5 14.5], 'Color', [1 1 1], 'LineStyle', ':')
    xlabel('bin')
    ylabel('Day')
    savefig([mouse, '_CSlaserUS_heatmap.fig'])
    saveas(gcf,[mouse,'_CSlaserUS_heatmap'],'png')
    close(gcf)
end


%% plot individual mice individual trial responses: unpaired extinction + laser
[output] = trialsAndDatesIntoSummaryData_individTrials_PCP2ChR2(txt,...
    raw, rbdat, 'unpaired extinction + laser', plotDataAnimals);

plotIndividAnimVals_PCP2ChR2(output, 'OK202', 'OK202: unpaired extinction + laser', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK202_unpairedExtinctionPlusLaser.fig')
saveas(gcf,'OK202_unpairedExtinctionPlusLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK203', 'OK203: unpaired extinction + laser', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.8])
savefig('OK203_unpairedExtinctionPlusLaser.fig')
saveas(gcf,'OK203_unpairedExtinctionPlusLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK204', 'OK204: unpaired extinction + laser', 1)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 1])
savefig('OK204_unpairedExtinctionPlusLaser.fig')
saveas(gcf,'OK204_unpairedExtinctionPlusLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK206', 'OK206: unpaired extinction + laser', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.8])
savefig('OK206_unpairedExtinctionPlusLaser.fig')
saveas(gcf,'OK206_unpairedExtinctionPlusLaser','png')
close(gcf)

[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'unpaired extinction + laser', plotDataAnimals, 10, 'CS trials');
blockEyetraceHeatmaps_PCP2ChR2(output, 'OK202', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK202: unpaired extinction + laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK202_unpairedExtinctionPlusLaser_CSheatmap.fig')
saveas(gcf,'OK202_unpairedExtinctionPlusLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK203', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK203: unpaired extinction + laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK203_unpairedExtinctionPlusLaser_CSheatmap.fig')
saveas(gcf,'OK203_unpairedExtinctionPlusLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK204', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK204: unpaired extinction + laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK204_unpairedExtinctionPlusLaser_CSheatmap.fig')
saveas(gcf,'OK204_unpairedExtinctionPlusLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK206', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK206: unpaired extinction + laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK206_unpairedExtinctionPlusLaser_CSheatmap.fig')
saveas(gcf,'OK206_unpairedExtinctionPlusLaser_CSheatmap','png')
close(gcf)

[output_US] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'unpaired extinction + laser', plotDataAnimals, 10, 'US only');
% need to align US output to puff in the baseline training days
[rows cols] = size(output_US.blockedEyelidpos);
for r = 1:rows
    for c = 1:cols
        if ~isempty(output_US.blockedEyelidpos{r,c})
            for i = 1:size(output_US.blockedEyelidpos{r,c},1)
                output_US.blockedEyelidpos{r,c}(i,:) = [nan(1,39), output_US.blockedEyelidpos{r, c}(i,1:end-39)];
            end
        end
    end
end
compiledOutput.blockedEyelidpos = [output.blockedEyelidpos(:,1:2),output_US.blockedEyelidpos(:,3:12),output.blockedEyelidpos(:,13:end)];
compiledOutput.mouse = output_US.mouse;
blockEyetraceHeatmaps_PCP2ChR2(compiledOutput, 'OK202', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('US trial')
title('OK202: unpaired extinction + laser, eyelidpos in 10-trial blocks')
colorbar
savefig('OK202_unpairedExtinctionPlusLaser_USheatmap.fig')
saveas(gcf,'OK202_unpairedExtinctionPlusLaser_USheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(compiledOutput, 'OK203', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('US trial')
title('OK203: unpaired extinction + laser, eyelidpos in 10-trial blocks')
colorbar
savefig('OK203_unpairedExtinctionPlusLaser_USheatmap.fig')
saveas(gcf,'OK203_unpairedExtinctionPlusLaser_USheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(compiledOutput, 'OK204', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('US trial')
title('OK204: unpaired extinction + laser, eyelidpos in 10-trial blocks')
colorbar
savefig('OK204_unpairedExtinctionPlusLaser_USheatmap.fig')
saveas(gcf,'OK204_unpairedExtinctionPlusLaser_USheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(compiledOutput, 'OK206', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('US trial')
title('OK206: unpaired extinction + laser, eyelidpos in 10-trial blocks')
colorbar
savefig('OK206_unpairedExtinctionPlusLaser_USheatmap.fig')
saveas(gcf,'OK206_unpairedExtinctionPlusLaser_USheatmap','png')
close(gcf)

%% plot group mean eyetraces across days of unpaired Extinction + laser
[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'unpaired extinction + laser', plotDataAnimals, 100, 'CS trials');
[rows cols] = size(output.blockedEyelidpos);
colormapvals = [];
for c = 1:cols
    temp = [];
    for r = 1:rows
        if ~isempty(output.blockedEyelidpos{r,c})
            temp = [temp; output.blockedEyelidpos{r,c}];
        else
            temp = [temp; nan(1,340)];
        end
    end
    if sum(~isnan(temp(:,1)))>1
        colormapvals = [colormapvals;nanmean(temp)];
    end
end
imagesc(colormapvals)
colorbar
hold on
for i = 1:size(colormapvals,1)
    plot([0 340], [i+0.5 i+0.5], 'Color', [1 1 1])
end
xlabel('bin')
ylabel('day')
title('Group mean daily eyelidpos: unpaired extinction + laser; CS trials only')
savefig('mean_UnpairedExtinctionPlusLaser_eyepos.fig')
saveas(gcf,'mean_UnpairedExtinctionPlusLaser_eyepos','png')
close(gcf)

[axhandles, fighandles] = plotGroupMedianVals_PCP2ChR2Pilot(txt, raw, rbdatDayData, 'unpaired extinction + laser', plotDataAnimals);
xlim(axhandles.a, [0.5 17.5])
ylim(axhandles.a, [0 0.75])
xlim(axhandles.b, [0.5 17.5])
ylim(axhandles.b, [0 0.75])
title(axhandles.a, 'Group Mean Unpaired Alone Extinction + Laser')
savefig(fighandles.a, 'mean_UnpairedExtinctionPlusLaser_FEC.fig')
saveas(fighandles.a,'mean_UnpairedExtinctionPlusLaser_FEC','png')
close(fighandles.a)
xlim(axhandles.c, [0.5 17.5])
ylim(axhandles.c, [0 1])
title(axhandles.c, 'Group Mean Unpaired Extinction + Laser')
savefig(fighandles.b, 'mean_UnpairedExtinctionPlusLaser_Prob.fig')
saveas(fighandles.b,'mean_UnpairedExtinctionPlusLaser_Prob','png')
close(fighandles.b)



%% plot individual mice individual trial responses: CS alone extinction + laser
[output] = trialsAndDatesIntoSummaryData_individTrials_PCP2ChR2(txt,...
    raw, rbdat, 'CS alone extinction + laser', plotDataAnimals);

plotIndividAnimVals_PCP2ChR2(output, 'OK202', 'OK202: CS alone extinction + laser', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK202_CSAloneExtinctionPlusLaser.fig')
saveas(gcf,'OK202_CSAloneExtinctionPlusLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK203', 'OK203: CS alone extinction + laser', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK203_CSAloneExtinctionPlusLaser.fig')
saveas(gcf,'OK203_CSAloneExtinctionPlusLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK204', 'OK204: CS alone extinction + laser', 1)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK204_CSAloneExtinctionPlusLaser.fig')
saveas(gcf,'OK204_CSAloneExtinctionPlusLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK206', 'OK206: CS alone extinction + laser', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK206_CSAloneExtinctionPlusLaser.fig')
saveas(gcf,'OK206_CSAloneExtinctionPlusLaser','png')
close(gcf)

[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'CS alone extinction + laser', plotDataAnimals, 10, 'CS trials');
blockEyetraceHeatmaps_PCP2ChR2(output, 'OK202', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK202: CS Alone extinction + laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK202_CSAloneExtinctionPlusLaser_CSheatmap.fig')
saveas(gcf,'OK202_CSAloneExtinctionPlusLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK203', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK203: CS Alone extinction + laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK203_CSAloneExtinctionPlusLaser_CSheatmap.fig')
saveas(gcf,'OK203_CSAloneExtinctionPlusLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK204', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK204: CS Alone extinction + laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK204_CSAloneExtinctionPlusLaser_CSheatmap.fig')
saveas(gcf,'OK204_CSAloneExtinctionPlusLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK206', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK206: CS Alone extinction + laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK206_CSAloneExtinctionPlusLaser_CSheatmap.fig')
saveas(gcf,'OK206_CSAloneExtinctionPlusLaser_CSheatmap','png')
close(gcf)

%% plot group mean eyetraces across days of adding CS Alone Extinction
[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'CS alone extinction + laser', plotDataAnimals, 100, 'CS trials');
[rows cols] = size(output.blockedEyelidpos);
colormapvals = [];
for c = 1:cols
    temp = [];
    for r = 1:rows
        if ~isempty(output.blockedEyelidpos{r,c})
            temp = [temp; output.blockedEyelidpos{r,c}];
        else
            temp = [temp; nan(1,340)];
        end
    end
    if sum(~isnan(temp(:,1)))>1
        colormapvals = [colormapvals;nanmean(temp)];
    end
end
imagesc(colormapvals)
colorbar
hold on
for i = 1:size(colormapvals,1)
    plot([0 340], [i+0.5 i+0.5], 'Color', [1 1 1])
end
xlabel('bin')
ylabel('day')
title('Group mean daily eyelidpos: CS alone extinction + laser')
savefig('mean_CSAloneExtinctionPlusLaser_eyepos.fig')
saveas(gcf,'mean_CSAloneExtinctionPlusLaser_eyepos','png')
close(gcf)

[axhandles, fighandles] = plotGroupMedianVals_PCP2ChR2Pilot(txt, raw, rbdatDayData, 'CS alone extinction + laser', plotDataAnimals);
xlim(axhandles.a, [0.5 14.5])
ylim(axhandles.a, [0 0.7])
xlim(axhandles.b, [0.5 14.5])
ylim(axhandles.b, [0 0.7])
title(axhandles.a, 'Group Mean CS Alone Extinction + Laser')
savefig(fighandles.a, 'mean_CSAloneExtinctionPlusLaser_FEC.fig')
saveas(fighandles.a,'mean_CSAloneExtinctionPlusLaser_FEC','png')
close(fighandles.a)
xlim(axhandles.c, [0.5 14.5])
ylim(axhandles.c, [0 1])
title(axhandles.c, 'Group Mean CS Alone Extinction + Laser')
savefig(fighandles.b, 'mean_CSAloneExtinctionPlusLaser_Prob.fig')
saveas(fighandles.b,'mean_CSAloneExtinctionPlusLaser_Prob','png')
close(fighandles.b)


%% plot individual mice individual trial responses: add 180 ms laser
[output] = trialsAndDatesIntoSummaryData_individTrials_PCP2ChR2(txt,...
    raw, rbdat, 'add 180 ms laser', plotDataAnimals);

plotIndividAnimVals_PCP2ChR2(output, 'OK202', 'OK202: add 180 ms laser', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK202_180msLaser.fig')
saveas(gcf,'OK202_180msLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK203', 'OK203:  add 180 ms laser', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK203_180msLaser.fig')
saveas(gcf,'OK203_180msLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK204', 'OK204:  add 180 ms laser', 1)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK204_180msLaser.fig')
saveas(gcf,'OK204_180msLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK206', 'OK206:  add 180 ms laser', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK206_180msLaser.fig')
saveas(gcf,'OK206_180msLaser','png')
close(gcf)

[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'add 180 ms laser', plotDataAnimals, 10, 'CS trials');
blockEyetraceHeatmaps_PCP2ChR2(output, 'OK202', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK202: 180 ms laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK202_180msLaser_CSheatmap.fig')
saveas(gcf,'OK202_180msLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK203', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK203: 180 ms laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK203_180msLaser_CSheatmap.fig')
saveas(gcf,'OK203_180msLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK204', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK204: 180 ms laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK204_180msLaser_CSheatmap.fig')
saveas(gcf,'OK204_180msLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK206', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK206: 180 ms laser, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK206_180msLaser_CSheatmap.fig')
saveas(gcf,'OK206_180msLaser_CSheatmap','png')
close(gcf)

[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'add 180 ms laser', plotDataAnimals, 100, 'CS trials');
figure
rectangle('Position', [76 0 820/5 1], 'EdgeColor', [0.85 0.85 0.85], 'FaceColor', [0.85 0.85 0.85])
dailyEyetraceLineplots_PCP2ChR2(output, 'OK202', 0)
xlim([20 340])
ylim([0 1])
title('OK202: FX of adding 180 ms laser (start on 3)')
savefig('OK202_180msLaser_CSLaserEyetraces.fig')
saveas(gcf,'OK202_180msLaser_CSLaserEyetraces','png')
close(gcf)

figure
rectangle('Position', [76 0 820/5 1], 'EdgeColor', [0.85 0.85 0.85], 'FaceColor', [0.85 0.85 0.85])
dailyEyetraceLineplots_PCP2ChR2(output, 'OK203', 0)
xlim([20 340])
ylim([0 1])
title('OK203: FX of adding 180 ms laser (start on 3)')
savefig('OK203_180msLaser_CSLaserEyetraces.fig')
saveas(gcf,'OK203_180msLaser_CSLaserEyetraces','png')
close(gcf)

figure
rectangle('Position', [76 0 820/5 1], 'EdgeColor', [0.85 0.85 0.85], 'FaceColor', [0.85 0.85 0.85])
dailyEyetraceLineplots_PCP2ChR2(output, 'OK204', 0)
xlim([20 340])
ylim([0 1])
title('OK204: FX of adding 180 ms laser (start on 3)')
savefig('OK204_180msLaser_CSLaserEyetraces.fig')
saveas(gcf,'OK204_180msLaser_CSLaserEyetraces','png')
close(gcf)

figure
rectangle('Position', [76 0 820/5 1], 'EdgeColor', [0.85 0.85 0.85], 'FaceColor', [0.85 0.85 0.85])
dailyEyetraceLineplots_PCP2ChR2(output, 'OK206', 0)
xlim([20 340])
ylim([0 1])
title('OK206: FX of adding 180 ms laser (start on 3)')
savefig('OK206_180msLaser_CSLaserEyetraces.fig')
saveas(gcf,'OK206_180msLaser_CSLaserEyetraces','png')
close(gcf)

%% plot group mean eyetraces across days of adding 180 ms laser
[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'add 180 ms laser', plotDataAnimals, 100, 'CS trials');
[rows cols] = size(output.blockedEyelidpos);
output.mouse{5,1} = 'mean';
for c = 1:cols
    temp = [];
    for r = 1:rows
        if ~isempty(output.blockedEyelidpos{r,c})
            temp = [temp; output.blockedEyelidpos{r,c}];
        else
            temp = [temp; nan(1,340)];
        end
    end
    output.blockedEyelidpos{5,c}(1,1:340) = nanmean(temp);
    output.blockedEyelidpos{5,c}(2,1:340) = nanstd(temp)/sqrt(sum(~isnan(temp(:,1))));
end
figure
colors = {'-b'; '-r'; '-c'; '-g'; '-y'; '-m'; '-k'};
hold on
for c = 1:cols-2
    shadedErrorBar(1:340, output.blockedEyelidpos{5,c}(1,:), output.blockedEyelidpos{5,c}(2,:), colors{c,1}, 1)
end
xlabel('time from CS')
ylabel('FEC - baseline')
title('Group mean daily eyetraces: adding 180 ms laser')
savefig('mean_180msLaser_Eyetraces.fig')
saveas(gcf,'mean_180msLaser_Eyetraces','png')
close(gcf)

[axhandles, fighandles] = plotGroupMedianVals_PCP2ChR2Pilot(txt, raw, rbdatDayData, 'add 180 ms laser', plotDataAnimals);
xlim(axhandles.a, [0.5 6.5])
ylim(axhandles.a, [0 0.8])
xlim(axhandles.b, [0.5 6.5])
ylim(axhandles.b, [0 0.8])
savefig(fighandles.a, 'mean_180msLaser_FEC.fig')
saveas(fighandles.a,'mean_180msLaser_FEC','png')
close(fighandles.a)
xlim(axhandles.c, [0.5 6.5])
ylim(axhandles.c, [0 1])
savefig(fighandles.b, 'mean_180msLaser_Prob.fig')
saveas(fighandles.b,'mean_180msLaser_Prob','png')
close(fighandles.b)



%% plot individual mice individual trial responses: 0 ms laser 30 mW
[output] = trialsAndDatesIntoSummaryData_individTrials_PCP2ChR2(txt,...
    raw, rbdat, '0 ms laser 30 mW', plotDataAnimals);

plotIndividAnimVals_PCP2ChR2(output, 'OK202', 'OK202: 0 ms laser 30 mW', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK202_0msLaser.fig')
saveas(gcf,'OK202_0msLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK203', 'OK203:  0 ms laser 30 mW', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK203_0msLaser.fig')
saveas(gcf,'OK203_0msLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK204', 'OK204:  0 ms laser 30 mW', 1)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK204_0msLaser.fig')
saveas(gcf,'OK204_0msLaser','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK206', 'OK206:  0 ms laser 30 mW', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK206_0msLaser.fig')
saveas(gcf,'OK206_0msLaser','png')
close(gcf)

[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, '0 ms laser 30 mW', plotDataAnimals, 10, 'CS trials');
blockEyetraceHeatmaps_PCP2ChR2(output, 'OK202', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK202: 0 ms laser 30 mW, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK202_0msLaser_CSheatmap.fig')
saveas(gcf,'OK202_0msLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK203', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK203: 0 ms laser 30 mW, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK203_0msLaser_CSheatmap.fig')
saveas(gcf,'OK203_0msLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK204', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK204: 0 ms laser 30 mW, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK204_0msLaser_CSheatmap.fig')
saveas(gcf,'OK204_0msLaser_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK206', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK206: 0 ms laser 30 mW, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK206_0msLaser_CSheatmap.fig')
saveas(gcf,'OK206_0msLaser_CSheatmap','png')
close(gcf)

[output_withlaser] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, '0 ms laser 30 mW', plotDataAnimals, 100, 'CS + laser');
[output_withoutlaser] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, '0 ms laser 30 mW', plotDataAnimals, 100, 'CS no laser');
output.blockedEyelidpos = [output_withoutlaser.blockedEyelidpos(:,1:2), output_withlaser.blockedEyelidpos(:,3:end)];
output.mouse = output_withoutlaser.mouse;
figure
subplot(1,2,1)
dailyEyetraceLineplots_PCP2ChR2(output_withoutlaser, 'OK202', 0)
xlim([20 340])
ylim([0 1])
subplot(1,2,2)
rectangle('Position', [40 0 820/5 1], 'EdgeColor', [0.85 0.85 0.85], 'FaceColor', [0.85 0.85 0.85])
dailyEyetraceLineplots_PCP2ChR2(output, 'OK202', 0)
xlim([20 340])
ylim([0 1])
title('OK202: 0 ms laser, 30 mW across days')
savefig('OK202_0msLaser_CSLaserEyetraces.fig')
saveas(gcf,'OK202_0msLaser_CSLaserEyetraces','png')
close(gcf)

figure
subplot(1,2,1)
dailyEyetraceLineplots_PCP2ChR2(output_withoutlaser, 'OK203', 0)
xlim([20 340])
ylim([0 1])
subplot(1,2,2)
rectangle('Position', [40 0 820/5 1], 'EdgeColor', [0.85 0.85 0.85], 'FaceColor', [0.85 0.85 0.85])
dailyEyetraceLineplots_PCP2ChR2(output, 'OK203', 0)
xlim([20 340])
ylim([0 1])
title('OK203: 0 ms laser, 30 mW across days')
savefig('OK203_0msLaser_CSLaserEyetraces.fig')
saveas(gcf,'OK203_0msLaser_CSLaserEyetraces','png')
close(gcf)

figure
subplot(1,2,1)
dailyEyetraceLineplots_PCP2ChR2(output_withoutlaser, 'OK206', 0)
xlim([20 340])
ylim([-0.05 1])
subplot(1,2,2)
rectangle('Position', [40 -0.05 820/5 1.05], 'EdgeColor', [0.85 0.85 0.85], 'FaceColor', [0.85 0.85 0.85])
dailyEyetraceLineplots_PCP2ChR2(output, 'OK206', 0)
xlim([20 340])
ylim([-0.05 1])
title('OK206: 0 ms laser, 30 mW across days')
savefig('OK206_0msLaser_CSLaserEyetraces.fig')
saveas(gcf,'OK206_0msLaser_CSLaserEyetraces','png')
close(gcf)

%% group data for 0 ms laser
[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, '0 ms laser 30 mW', plotDataAnimals, 100, 'CS trials');
[rows cols] = size(output.blockedEyelidpos);
colormapvals = [];
for c = 1:cols
    temp = [];
    for r = 1:rows
        if ~isempty(output.blockedEyelidpos{r,c})
            temp = [temp; output.blockedEyelidpos{r,c}];
        else
            temp = [temp; nan(1,340)];
        end
    end
    if sum(~isnan(temp(:,1)))>1
        colormapvals = [colormapvals;nanmean(temp)];
    end
end
imagesc(colormapvals)
colorbar
hold on
for i = 1:size(colormapvals,1)
    plot([0 340], [i+0.5 i+0.5], 'Color', [1 1 1])
end
plot([40 40], [0 6.5], 'Color', [1 1 1], 'LineStyle', ':')
plot([86 86], [0 6.5], 'Color', [1 1 1], 'LineStyle', ':')
xlabel('bin')
ylabel('day')
title('Group mean daily eyelidpos: 0 ms laser 30 mW; CS trials only')
savefig('mean_0msLaser30mW_eyepos.fig')
saveas(gcf,'mean_0msLaser30mW_eyepos','png')
close(gcf)

[axhandles, fighandles] = plotGroupMedianVals_PCP2ChR2Pilot(txt, raw, rbdatDayData, '0 ms laser 30 mW', plotDataAnimals);
xlim(axhandles.a, [0.5 7.5])
ylim(axhandles.a, [0 0.75])
xlim(axhandles.b, [0.5 7.5])
ylim(axhandles.b, [0 0.75])
title(axhandles.a, 'Group Mean 0 ms laser 30 mW')
savefig(fighandles.a, 'mean_0msLaser30mW_FEC.fig')
saveas(fighandles.a,'mean_0msLaser30mW_FEC','png')
close(fighandles.a)
xlim(axhandles.c, [0.5 7.5])
ylim(axhandles.c, [0 1])
title(axhandles.c, 'Group Mean 0 ms laser 30 mW')
savefig(fighandles.b, 'mean_0msLaser30mW_Prob.fig')
saveas(fighandles.b,'mean_0msLaser30mW_Prob','png')
close(fighandles.b)

%% plot individual mice individual trial responses: 0 ms laser 60 mW
[output] = trialsAndDatesIntoSummaryData_individTrials_PCP2ChR2(txt,...
    raw, rbdat, '0 ms laser 60 mW', plotDataAnimals);

plotIndividAnimVals_PCP2ChR2(output, 'OK202', 'OK202: 0 ms laser 60 mW', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK202_0msLaser60.fig')
saveas(gcf,'OK202_0msLaser60','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK204', 'OK204:  0 ms laser 60 mW', 1)
subplot(5,1,1)
xlim([100 431])
subplot(5,1,2)
xlim([100 431])
subplot(5,1,3)
ylim([0 0.3])
xlim([100 431])
subplot(5,1,4)
ylim([0 0.3])
xlim([100 431])
subplot(5,1,5)
xlim([100 400])
savefig('OK204_0msLaser60.fig')
saveas(gcf,'OK204_0msLaser60','png')
close(gcf)

%% plot OK204 initial round of 0 ms laser days
[output] = trialsAndDatesIntoSummaryData_individTrials_PCP2ChR2(txt,...
    raw, rbdat, '0 ms laser 30 mW dbl', plotDataAnimals);


plotIndividAnimVals_PCP2ChR2(output, 'OK204', 'OK204:  0 ms laser 30 mW', 1)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK204_0msLaserdbl.fig')
saveas(gcf,'OK204_0msLaserdbl','png')
close(gcf)

[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, '0 ms laser 30 mW dbl', plotDataAnimals, 10, 'CS trials');
blockEyetraceHeatmaps_PCP2ChR2(output, 'OK204', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([76 76], [0 340], 'LineStyle', '--', 'Color', [1 1 1])
ylabel('CS trial')
title('OK204: 0 ms laser 30 mW dbl, eyelidpos in 10-trial blocks')
plot([240 240], [0 320], 'LineStyle', '--', 'Color', [1 1 1])
colorbar
savefig('OK204_0msLaserdbl_CSheatmap.fig')
saveas(gcf,'OK204_0msLaserdbl_CSheatmap','png')
close(gcf)


[output_withlaser] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, '0 ms laser 30 mW dbl', plotDataAnimals, 100, 'CS + laser');
figure
rectangle('Position', [40 -0.05 820/5 1.05], 'EdgeColor', [0.85 0.85 0.85], 'FaceColor', [0.85 0.85 0.85])
dailyEyetraceLineplots_PCP2ChR2(output_withlaser, 'OK204', 0)
xlim([20 340])
ylim([-0.05 1])
title('OK204: 0 ms laser, 30 mW dbl across days')
savefig('OK204_0msLaserdbl_CSLaserEyetraces.fig')
saveas(gcf,'OK204_0msLaserdbl_CSLaserEyetraces','png')
close(gcf)

%% check for relationship between CR probability and rebound probability: individual mice
for m = 1:length(mice)
    idx = ~isnan(rbdatDayData.RBProb) & strcmpi(rbdatDayData.mouse, mice(m,1).name);
    if sum(idx)>0
        figure
        scatter(rbdatDayData.CRProb(idx), rbdatDayData.RBProb(idx), 3, 'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [0 0 1])
        lsline
        xlabel('CR Probability')
        ylabel('RB Probability')
        [rho, pval] = corr(rbdatDayData.CRProb(idx), rbdatDayData.RBProb(idx), 'Type', 'Spearman');
        title([mice(m,1).name, ': CR Prob x RB Prob for each session with laser stimulation'])
        text(0.1, 0.8, ['r = ', num2str(rho), ', p = ', num2str(pval)])
        savefig([mice(m,1).name, '_CRProbxRBProb.fig'])
        saveas(gcf,[mice(m,1).name, '_CRProbxRBProb'],'png')
        close(gcf)
    end
end

for m = 1:length(mice)
    idx = ~isnan(rbdatDayData.RBProb) & strcmpi(rbdatDayData.mouse, mice(m,1).name);
    if sum(idx)>0
        figure
        scatter(rbdatDayData.FEC230(idx), rbdatDayData.RBProb(idx), 3, 'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [0 0 1])
        lsline
        xlabel('CR Probability')
        ylabel('RB Probability')
        [rho, pval] = corr(rbdatDayData.FEC230(idx), rbdatDayData.RBProb(idx), 'Type', 'Spearman');
        title([mice(m,1).name, ': CR Amp x RB Prob for each session with laser stimulation'])
        text(0.1, 0.8, ['r = ', num2str(rho), ', p = ', num2str(pval)])
        savefig([mice(m,1).name, '_CRAmpxRBProb.fig'])
        saveas(gcf,[mice(m,1).name, '_CRAmpxRBProb'],'png')
        close(gcf)
    end
end



[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'rb before and after training', plotDataAnimals, 100, 'Laser Only');

% need to go get the data from 190228 -- wasn't collected by the
% concatenate behavior data function
cd('L:\users\okim\behavior\OK202\190228')
load('trialdata.mat')
idx = trials.laser.dur>0;
pretraindat.eyelidpos = trials.eyelidpos(idx,:);
pretraindat.mouse = {};
[pretraindat.mouse{1:sum(idx),1}] = deal('OK202');
pretraindat.day = 190228 * ones(sum(idx),1);
cd('L:\users\okim\behavior\OK203\190228')
load('trialdata.mat')
idx = trials.laser.dur>0;
pretraindat.eyelidpos = [pretraindat.eyelidpos;trials.eyelidpos(idx,:)];
temp = {};
[temp{1:sum(idx),1}] = deal('OK203');
pretraindat.mouse = [pretraindat.mouse; temp];
temp2 = 190228 * ones(sum(idx),1);
pretraindat.day = [pretraindat.day; temp2];
cd('L:\users\okim\behavior\OK204\190228')
load('trialdata.mat')
idx = trials.laser.dur>0;
pretraindat.eyelidpos = [pretraindat.eyelidpos;trials.eyelidpos(idx,:)];
temp = {};
[temp{1:sum(idx),1}] = deal('OK204');
pretraindat.mouse = [pretraindat.mouse; temp];
temp2 = 190228 * ones(sum(idx),1);
pretraindat.day = [pretraindat.day; temp2];
cd('L:\users\okim\behavior\OK206\190228')
load('trialdata.mat')
idx = trials.laser.dur>0;
pretraindat.eyelidpos = [pretraindat.eyelidpos;trials.eyelidpos(idx,:)];
temp = {};
[temp{1:sum(idx),1}] = deal('OK206');
pretraindat.mouse = [pretraindat.mouse; temp];
temp2 = 190228 * ones(sum(idx),1);
pretraindat.day = [pretraindat.day; temp2];

for m = 1:4
    idx = strcmpi(pretraindat.mouse, mice(m,1).name);
    temp = mean(pretraindat.eyelidpos(idx,:));
    output.blockedEyelidpos{m,2} = temp;
end

output.mouse{5,1} = 'mean';
for c = 2:3
    temp = [];
    for m = 1:4
        temp = [temp; output.blockedEyelidpos{m,c}];
    end
    output.blockedEyelidpos{5,c} = nanmean(temp);
end

cd(saveDir)

for i = 1:size(output.blockedEyelidpos,1)
    figure
    plot(output.blockedEyelidpos{i,2}(1,120:end)')
    hold on
    plot(output.blockedEyelidpos{i,3}(1,40:end)')
    title(output.mouse{i,1})
    xlabel('bins from laser offset')
    legend('before training', 'after training')
    savefig([output.mouse{i,1}, '_RBBeforeAfterTraining.fig'])
    saveas(gcf,[output.mouse{i,1}, '_RBBeforeAfterTraining'],'png')
    close(gcf)
    
    figure
    plot(output.blockedEyelidpos{i,2}')
    hold on
    plot(output.blockedEyelidpos{i,3}')
    title(output.mouse{i,1})
    xlabel('bins from laser onset')
    legend('before training', 'after training')
    savefig([output.mouse{i,1}, '_RBBeforeAfterTraining_onsetAligned.fig'])
    saveas(gcf,[output.mouse{i,1}, '_RBBeforeAfterTraining_onsetAligned'],'png')
    close(gcf)
end

disp('DONE RUNNING THROUGH THINGS WRITTEN ON 190520')


%% plot individual mice individual trial responses: WT regular unpaired extinction
[output] = trialsAndDatesIntoSummaryData_individTrials_PCP2ChR2(txt,...
    raw, rbdat, 'unpaired extinction', plotDataAnimals);

plotIndividAnimVals_PCP2ChR2(output, 'OK207', 'OK207: unpaired extinction', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.3])
savefig('OK207_unpairedExtinction.fig')
saveas(gcf,'OK207_unpairedExtinction','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK208', 'OK208: unpaired extinction', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.8])
savefig('OK208_unpairedExtinction.fig')
saveas(gcf,'OK208_unpairedExtinction','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK209', 'OK209: unpaired extinction', 1)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 1])
savefig('OK209_unpairedExtinction.fig')
saveas(gcf,'OK209_unpairedExtinction','png')
close(gcf)

plotIndividAnimVals_PCP2ChR2(output, 'OK210', 'OK210: unpaired extinction', 0)
subplot(5,1,3)
ylim([0 0.3])
subplot(5,1,4)
ylim([0 0.8])
savefig('OK210_unpairedExtinction.fig')
saveas(gcf,'OK210_unpairedExtinction','png')
close(gcf)

[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'unpaired extinction', plotDataAnimals, 10, 'CS trials');
blockEyetraceHeatmaps_PCP2ChR2(output, 'OK207', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK207: unpaired extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK207_unpairedExtinction_CSheatmap.fig')
saveas(gcf,'OK207_unpairedExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK208', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK208: unpaired extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK208_unpairedExtinction_CSheatmap.fig')
saveas(gcf,'OK208_unpairedExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK209', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK209: unpaired extinction + laser, eyelidpos in 10-trial blocks')
colorbar
savefig('OK209_unpairedExtinction_CSheatmap.fig')
saveas(gcf,'OK209_unpairedExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK210', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK210: unpaired extinction , eyelidpos in 10-trial blocks')
colorbar
savefig('OK210_unpairedExtinction_CSheatmap.fig')
saveas(gcf,'OK210_unpairedExtinction_CSheatmap','png')
close(gcf)

[output_US] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'unpaired extinction', plotDataAnimals, 10, 'US only');
% need to align US output to puff in the baseline training days
[rows cols] = size(output_US.blockedEyelidpos);
for r = 1:rows
    for c = 1:cols
        if ~isempty(output_US.blockedEyelidpos{r,c})
            for i = 1:size(output_US.blockedEyelidpos{r,c},1)
                output_US.blockedEyelidpos{r,c}(i,:) = [nan(1,39), output_US.blockedEyelidpos{r, c}(i,1:end-39)];
            end
        end
    end
end
compiledOutput.blockedEyelidpos = [output.blockedEyelidpos(:,1:2),output_US.blockedEyelidpos(:,3:12),output.blockedEyelidpos(:,13:end)];
compiledOutput.mouse = output_US.mouse;
blockEyetraceHeatmaps_PCP2ChR2(compiledOutput, 'OK207', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('US trial')
title('OK207: unpaired extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK207_unpairedExtinction_USheatmap.fig')
saveas(gcf,'OK207_unpairedExtinction_USheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(compiledOutput, 'OK208', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('US trial')
title('OK208: unpaired extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK208_unpairedExtinction_USheatmap.fig')
saveas(gcf,'OK208_unpairedExtinction_USheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(compiledOutput, 'OK209', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('US trial')
title('OK209: unpaired extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK209_unpairedExtinction_USheatmap.fig')
saveas(gcf,'OK209_unpairedExtinction_USheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(compiledOutput, 'OK210', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('US trial')
title('OK210: unpaired extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK210_unpairedExtinction_USheatmap.fig')
saveas(gcf,'OK210_unpairedExtinction_USheatmap','png')
close(gcf)

%% plot group mean eyetraces across days of WT unpaired extinction
[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'unpaired extinction', plotDataAnimals, 100, 'CS trials');
[rows cols] = size(output.blockedEyelidpos);
colormapvals = [];
for c = 1:cols
    temp = [];
    for r = 1:rows
        if ~isempty(output.blockedEyelidpos{r,c})
            temp = [temp; output.blockedEyelidpos{r,c}];
        else
            temp = [temp; nan(1,340)];
        end
    end
    if sum(~isnan(temp(:,1)))>1
        colormapvals = [colormapvals;nanmean(temp)];
    end
end
imagesc(colormapvals)
colorbar
hold on
for i = 1:size(colormapvals,1)
    plot([0 340], [i+0.5 i+0.5], 'Color', [1 1 1])
end
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
xlabel('bin')
ylabel('day')
title('Group mean daily eyelidpos: unpaired extinction')
savefig('mean_UnpairedExtinction_eyepos.fig')
saveas(gcf,'mean_UnpairedExtinction_eyepos','png')
close(gcf)

[output_US] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'unpaired extinction', plotDataAnimals, 100, 'US only');
newoutput = {};
for r = 1:rows
    for c = 1:cols
        if c<=2 || c>=13
            newoutput{r,c} = output.blockedEyelidpos{r,c};
        else
            if ~isempty(output_US.blockedEyelidpos{r,c})
                newoutput{r,c} = [nan(1,39),output_US.blockedEyelidpos{r,c}(1,1:end-39)];
            end
        end
    end
end
colormapvals = [];
[rows cols] = size(newoutput);
for c = 1:cols
    temp = [];
    for r = 1:rows
        if ~isempty(newoutput{r,c})
            temp = [temp; newoutput{r,c}];
        else
            temp = [temp; nan(1,340)];
        end
    end
    
    colormapvals = [colormapvals;nanmean(temp)];
    
end
imagesc(colormapvals)
colorbar
hold on
for i = 1:size(colormapvals,1)
    plot([0 340], [i+0.5 i+0.5], 'Color', [1 1 1])
end
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
xlabel('bin')
ylabel('day')
title('Group mean daily eyelidpos: unpaired extinction: US trials')
savefig('mean_UnpairedExtinction_eyeposUStrials.fig')
saveas(gcf,'mean_UnpairedExtinction_eyeposUStrials','png')
close(gcf)

[axhandles, fighandles] = plotGroupMedianVals_WT(txt, raw, rbdatDayData, 'unpaired extinction', plotDataAnimals);
xlim(axhandles.a, [0.5 17.5])
ylim(axhandles.a, [0 0.65])
xlim(axhandles.b, [0.5 17.5])
ylim(axhandles.b, [0 0.65])
title(axhandles.a, 'Group Mean Unpaired Extinction')
savefig(fighandles.a, 'mean_UnpairedExtinction_FEC.fig')
saveas(fighandles.a,'mean_UnpairedExtinction_FEC','png')
close(fighandles.a)
xlim(axhandles.c, [0.5 17.5])
ylim(axhandles.c, [0 1])
title(axhandles.c, 'Group Mean Unpaired Extinction')
savefig(fighandles.b, 'mean_UnpairedExtinction_Prob.fig')
saveas(fighandles.b,'mean_UnpairedExtinction_Prob','png')
close(fighandles.b)

%% check the data from CS alone extinction animals
cd(behDataDir)

%% load behavior data
load('190521_WTLEDCSUnpExt.mat') % idk why I have misnamed this data vector....
load('190521_WTLEDCSUnpExt_timeVector.mat')

if strcmp(machine, 'ALBUS')
    cd('C:\olivia\data\data summaries\IO inhibition extinction project\spreadsheets')
elseif strcmp(machine,'OREK')
    cd('E:\data\spreadsheets')
end
[num, txt, raw] = xlsread('WTCSAloneExt.xlsx');

%% set up the plotData organization (will wind up being in alphabetical order)
plotDataAnimals = unique(rbdat.mouse);

%% get trial by trial data
for t = 1:length(rbdat.tDay)
    if rbdat.c_csdur(t,1)>0
        rbdat.FEC180(t,1) = rbdat.eyelidpos(t,76) - rbdat.baseline(t,1);
        rbdat.FEC220(t,1) = rbdat.eyelidpos(t,84) - rbdat.baseline(t,1);
    else
        rbdat.FEC180(t,1) = NaN;
        rbdat.FEC220(t,1) = NaN;
    end
end

%% get day by day data
% FEC180
% FEC230
rbdatDayData.mouse = {};
rbdatDayData.date = [];
rbdatDayData.CRProb = [];
rbdatDayData.FEC180 = [];
rbdatDayData.FEC220 = [];
csidx = rbdat.c_csdur>0;
for m = 1:length(plotDataAnimals)
    thisMouseIdx = strcmpi(rbdat.mouse,plotDataAnimals(m,1));
    days = unique(rbdat.date(thisMouseIdx,1));
    for d = 1:length(days)
        thisDayIdx = rbdat.date == days(d,1);
        fec180vals = rbdat.FEC180(thisDayIdx & thisMouseIdx & csidx,1);
        fec220vals = rbdat.FEC220(thisDayIdx & thisMouseIdx & csidx,1);
        numtrials = length(fec180vals);
        crprob = sum(fec180vals > 0.1)./numtrials; 

        rbdatDayData.mouse = [rbdatDayData.mouse; plotDataAnimals(m,1)];
        rbdatDayData.date = [rbdatDayData.date; days(d,1)];
        rbdatDayData.CRProb = [rbdatDayData.CRProb; crprob];
        rbdatDayData.FEC180 = [rbdatDayData.FEC180; nanmean(fec180vals)];
        rbdatDayData.FEC220 = [rbdatDayData.FEC220; nanmean(fec220vals)];
                
        clear fec180vals fec220vals numtrials crprob
    end
end

cd(saveDir)

%% plot individual mice individual trial responses: unpaired extinction + laser
[output] = trialsAndDatesIntoSummaryData_individTrials_WTCSAloneExt(txt,...
    raw, rbdat, 'CS alone extinction', plotDataAnimals);

plotIndividAnimVals_WTCSAloneExt(output, 'OK001', 'OK001: CS alone extinction', 0)
savefig('OK001_CSAloneExt.fig')
saveas(gcf,'OK001_CSAloneExt','png')
close(gcf)

plotIndividAnimVals_WTCSAloneExt(output, 'OK002', 'OK002: CS alone extinction', 0)
savefig('OK002_CSAloneExt.fig')
saveas(gcf,'OK002_CSAloneExt','png')
close(gcf)

plotIndividAnimVals_WTCSAloneExt(output, 'OK003', 'OK003: CS alone extinction', 0)
savefig('OK003_CSAloneExt.fig')
saveas(gcf,'OK003_CSAloneExt','png')
close(gcf)

plotIndividAnimVals_WTCSAloneExt(output, 'OK004', 'OK004: CS alone extinction', 0)
savefig('OK004_CSAloneExt.fig')
saveas(gcf,'OK004_CSAloneExt','png')
close(gcf)

plotIndividAnimVals_WTCSAloneExt(output, 'OK005', 'OK005: CS alone extinction', 0)
savefig('OK005_CSAloneExt.fig')
saveas(gcf,'OK005_CSAloneExt','png')
close(gcf)

plotIndividAnimVals_WTCSAloneExt(output, 'OK006', 'OK006: CS alone extinction', 0)
savefig('OK006_CSAloneExt.fig')
saveas(gcf,'OK006_CSAloneExt','png')
close(gcf)

plotIndividAnimVals_WTCSAloneExt(output, 'OK007', 'OK007: CS alone extinction', 0)
savefig('OK007_CSAloneExt.fig')
saveas(gcf,'OK007_CSAloneExt','png')
close(gcf)

plotIndividAnimVals_WTCSAloneExt(output, 'OK008', 'OK008: CS alone extinction', 0)
savefig('OK008_CSAloneExt.fig')
saveas(gcf,'OK008_CSAloneExt','png')
close(gcf)

[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'CS Alone Extinction', plotDataAnimals, 10, 'CS trials');
blockEyetraceHeatmaps_PCP2ChR2(output, 'OK001', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK001: CS Alone Extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK001_CSAloneExtinction_CSheatmap.fig')
saveas(gcf,'OK001_CSAloneExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK002', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK002: CS Alone Extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK002_CSAloneExtinction_CSheatmap.fig')
saveas(gcf,'OK002_CSAloneExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK003', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK003: CS Alone Extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK003_CSAloneExtinction_CSheatmap.fig')
saveas(gcf,'OK003_CSAloneExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK004', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK004: CS Alone Extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK004_CSAloneExtinction_CSheatmap.fig')
saveas(gcf,'OK004_CSAloneExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK005', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK005: CS Alone Extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK005_CSAloneExtinction_CSheatmap.fig')
saveas(gcf,'OK005_CSAloneExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK006', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK006: CS Alone Extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK006_CSAloneExtinction_CSheatmap.fig')
saveas(gcf,'OK006_CSAloneExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK007', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK007: CS Alone Extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK007_CSAloneExtinction_CSheatmap.fig')
saveas(gcf,'OK007_CSAloneExtinction_CSheatmap','png')
close(gcf)

blockEyetraceHeatmaps_PCP2ChR2(output, 'OK008', [1 340]);
plot([40 40], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
plot([83 83], [0 340], 'LineStyle', ':', 'Color', [1 1 1])
ylabel('CS trial')
title('OK008: CS Alone Extinction, eyelidpos in 10-trial blocks')
colorbar
savefig('OK008_CSAloneExtinction_CSheatmap.fig')
saveas(gcf,'OK008_CSAloneExtinction_CSheatmap','png')
close(gcf)


%% plot group mean eyetraces across days of unpaired Extinction + laser
[output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(txt,...
    raw, rbdat, 'CS Alone Extinction', plotDataAnimals, 100, 'CS trials');
[rows cols] = size(output.blockedEyelidpos);
colormapvals = [];
for c = 1:cols
    temp = [];
    for r = 1:rows
        if ~isempty(output.blockedEyelidpos{r,c})
            temp = [temp; [output.blockedEyelidpos{r,c}, nan(1,140)]];
        else
            temp = [temp; nan(1,340)];
        end
    end
    if sum(~isnan(temp(:,1)))>1
        colormapvals = [colormapvals;nanmean(temp)];
    end
end
imagesc(colormapvals)
colorbar
hold on
for i = 1:size(colormapvals,1)
    plot([0 340], [i+0.5 i+0.5], 'Color', [1 1 1])
end
xlabel('bin')
ylabel('day')
title('Group mean daily eyelidpos: CS Alone Extinction')
savefig('mean_CSAloneExtinction_eyepos.fig')
saveas(gcf,'mean_CSAloneExtinction_eyepos','png')
close(gcf)

[axhandles, fighandles] = plotGroupMedianVals_WTCSAloneExt(txt, raw, rbdatDayData, 'CS Alone Extinction', plotDataAnimals);
xlim(axhandles.a, [0.5 15.5])
ylim(axhandles.a, [0 0.8])
title(axhandles.a, 'Group Mean CS Alone Extinction')
savefig(fighandles.a, 'mean_CSAloneExtinction_FEC.fig')
saveas(fighandles.a,'mean_CSAloneExtinction_FEC','png')
close(fighandles.a)
xlim(axhandles.c, [0.5 15.5])
ylim(axhandles.c, [0 1])
title(axhandles.c, 'Group Mean CS Alone Extinctionr')
savefig(fighandles.b, 'mean_CSAloneExtinction_Prob.fig')
saveas(fighandles.b,'mean_CSAloneExtinction_Prob','png')
close(fighandles.b)