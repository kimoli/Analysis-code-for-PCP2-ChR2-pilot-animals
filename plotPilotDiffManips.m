%%% This function takes data structures from
%%% OK135_137_138_134_148_grouped_V5 and plots them together in a uniform
%%% way. The function takes the following inputs:
%%%         during, after, late, early      data structures for the
%%%                     parameter of interest, should have data field
%%%         label       a string corresponding to the name of your
%%%                     parameter
%%%         yrange      ymin and max
%%%         xrange      xmin and max
% ONLY THE MEDIAN PART OF THIS FUNCTION HAS BEEN ADAPTED FOR THE PCP2CHR2
% MICE

function [data]= plotPilotDiffManips...
    (data, label, yrange, xrange, type,...
    inputMouseIdx, plotMice)

colordef black


%% figure out the indices that should be plotted for each group
mouseIdx = nan(length(plotMice),1);
for e = 1:length(plotMice)
    mouseIdx(e,1) = find(strcmp(inputMouseIdx, plotMice(e,1)));
end

%% compute mean/sem values for the cr probability plots
% Each column in the plotData structure corresponds to its own day
if strcmpi(type,'mean')
    data.mean = nan(1,18);
    data.stdev = nan(1,18);
    data.n = nan(1,18);
    data.sem = nan(1,18);
    
    for c = 1:18 % go through each column in the plotData structure and get experimental animal data
        % this part of the code depends on there being exactly 4 animals in each
        % condition
        data.mean(1,c) = nanmean(data.data(mouseIdx,c));
        data.stdev(1,c) = nanstd(data.data(mouseIdx,c));
        data.n(1,c) = sum(~isnan(data.data(mouseIdx,c)));
        data.sem(1,c) = data.stdev(1,c)/sqrt(data.n(1,c));
    end
    
    %% plot
    handles.during = figure;
    a = errorbar([1:18], data.mean(1,:), data.sem(1,:), '.');
    e = plot([2.5 2.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    f = plot([12.5 12.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    xlim(xrange)
    ylim(yrange)
    tempstring = strcat(label, 'during laser stim: averaged across mice +/- SEM');
    title(tempstring)
    legend('experimental', 'Location', 'NorthOutside')
    xlabel('session')
    ylabel(label)
    
   
elseif strcmpi(type, 'median with mad')
    data.median = nan(1,18);
    data.mad = nan(1,18);
    data.n = nan(1,18);
    for c = 1:18 % go through each column in the plotData structure and get experimental animal data
        % this part of the code depends on there being exactly 4 animals in each
        % condition
        data.median(1,c) = nanmedian(data.data(mouseIdx,c));
        temp = data.data(mouseIdx,c);
        nonantemp = ~isnan(temp);
        data.mad(1,c) = mad(temp(nonantemp),1);
        data.n(1,c) = sum(~isnan(data.data(mouseIdx,c)));
    end
   
    
    %% plot
    handles.during = figure;
    a = errorbar([1:18], data.median(1,:), data.mad(1,:), '.');
    hold on
    e = plot([2.5 2.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    f = plot([12.5 12.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    xlim(xrange)
    ylim(yrange)
    tempstring = strcat(label, 'during laser stim: median across mice +/- med abs dev');
    title(tempstring)
    legend('experimental', 'Location', 'NorthOutside')
    xlabel('session')
    ylabel(label)
    
    
elseif strcmpi(type, 'median')
    data.med = nan(1,18);
    data.n = nan(1,18);
    for c = 1:18 % go through each column in the plotData structure and get experimental animal data
        % this part of the code depends on there being exactly 4 animals in each
        % condition
        tempquants = quantile(data.data(mouseIdx,c), 3);
        data.med(1,c) = tempquants(2);
        data.quantile1(1,c) = tempquants(1);
        data.quantile3(1,c) = tempquants(3);
        data.n(1,c) = sum(~isnan(data.data(mouseIdx,c)));
    end
    
    %% plot
    handles.during = figure;
    a = plot([1:18], data.med(1,:), '.', 'Color', [1 0 1], 'MarkerSize', 20);
    hold on
    for i = 1:18
        abars = plot([i i], [data.quantile1(1,i),data.quantile3(1,i)], ...
            'Color', [1 0 1]);
    end
    e = plot([2.5 2.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [1 1 1]);
    f = plot([12.5 12.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [1 1 1]);
    xlim(xrange)
    ylim(yrange)
    tempstring = strcat(label, 'CS + Laser + US: median across mice +/- quartiles');
    title(tempstring)
    legend([a],'experimental', 'Location', 'NorthOutside')
    xlabel('session')
    ylabel(label)
    
end
end