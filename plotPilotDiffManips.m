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

function [csuslaser, cslaser, cslaserus, unpext, handles]= plotPilotDiffManips...
    (csuslaser, cslaser, cslaserus, unpext, label, yrange, xrange, type,...
    inputMouseIdx, experimentalMice, controlMice)

colordef black


%% figure out the indices that should be plotted for each group
expIdx = nan(length(experimentalMice),1);
for e = 1:length(experimentalMice)
    expIdx(e,1) = find(strcmp(inputMouseIdx, experimentalMice(e,1)));
end
contIdx = nan(length(controlMice),1);
for e = 1:length(controlMice)
    contIdx(e,1) = find(strcmp(inputMouseIdx, controlMice(e,1)));
end

%% compute mean/sem values for the cr probability plots
% Each column in the plotData structure corresponds to its own day
if strcmpi(type,'mean')
    csuslaser.mean = nan(1,18);
    csuslaser.stdev = nan(1,18);
    csuslaser.n = nan(1,18);
    csuslaser.sem = nan(1,18);
    cslaser.mean = nan(1,18);
    cslaser.stdev = nan(1,18);
    cslaser.n = nan(1,18);
    cslaser.sem = nan(1,18);
    cslaserus.mean = nan(1,18);
    cslaserus.stdev = nan(1,18);
    cslaserus.n = nan(1,18);
    cslaserus.sem = nan(1,18);
    
    for c = 1:18 % go through each column in the plotData structure and get experimental animal data
        % this part of the code depends on there being exactly 4 animals in each
        % condition
        csuslaser.mean(1,c) = nanmean(csuslaser.data(expIdx,c));
        csuslaser.stdev(1,c) = nanstd(csuslaser.data(expIdx,c));
        csuslaser.n(1,c) = sum(~isnan(csuslaser.data(expIdx,c)));
        csuslaser.sem(1,c) = csuslaser.stdev(1,c)/sqrt(csuslaser.n(1,c));
        cslaser.mean(1,c) = nanmean(cslaser.data(expIdx,c));
        cslaser.stdev(1,c) = nanstd(cslaser.data(expIdx,c));
        cslaser.n(1,c) = sum(~isnan(cslaser.data(expIdx,c)));
        cslaser.sem(1,c) = cslaser.stdev(1,c)/sqrt(cslaser.n(1,c));
        cslaserus.mean(1,c) = nanmean(cslaserus.data(expIdx,c));
        cslaserus.stdev(1,c) = nanstd(cslaserus.data(expIdx,c));
        cslaserus.n(1,c) = sum(~isnan(cslaserus.data(expIdx,c)));
        cslaserus.sem(1,c) = cslaserus.stdev(1,c)/sqrt(4);
    end
    
    %% plot
    handles.during = figure;
    a = errorbar([1:18], csuslaser.mean(1,:), csuslaser.sem(1,:), '.');
    hold on
    b = errorbar([1:18], csuslaser.mean(2,:), csuslaser.sem(2,:), '.');
    e = plot([2.5 2.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    f = plot([12.5 12.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    xlim(xrange)
    ylim(yrange)
    tempstring = strcat(label, 'during laser stim: averaged across mice +/- SEM');
    title(tempstring)
    legend('experimental', 'Location', 'NorthOutside')
    xlabel('session')
    ylabel(label)
    
   
    handles.afterlate = figure;
    b = errorbar([1:18], cslaser.mean, cslaser.sem, '.');
    hold on
    c = errorbar([1:18], cslaserus.mean, cslaserus.sem, '.');
    e = plot([2.5 2.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    f = plot([12.5 12.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    xlim(xrange)
    ylim(yrange)
    tempstring = strcat(label, 'expt only: averaged across mice +/- SEM');
    title(tempstring)
    legend('CS + laser extinction', 'CS + laser alt US alone extinction', 'Location', 'NorthOutside')
    xlabel('session')
    ylabel(label)
elseif strcmpi(type, 'median with mad')
    csuslaser.median = nan(1,18);
    csuslaser.mad = nan(1,18);
    csuslaser.n = nan(1,18);
    cslaser.median = nan(1,18);
    cslaser.mad = nan(1,18);
    cslaser.n = nan(1,18);
    cslaserus.median = nan(1,18);
    cslaserus.mad = nan(1,18);
    cslaserus.n = nan(1,18);
    early.median = nan(1,18);
    early.mad = nan(1,18);
    early.n = nan(1,18);
    for c = 1:18 % go through each column in the plotData structure and get experimental animal data
        % this part of the code depends on there being exactly 4 animals in each
        % condition
        csuslaser.median(1,c) = nanmedian(csuslaser.data(expIdx,c));
        temp = csuslaser.data(expIdx,c);
        nonantemp = ~isnan(temp);
        csuslaser.mad(1,c) = mad(temp(nonantemp),1);
        csuslaser.n(1,c) = sum(~isnan(csuslaser.data(expIdx,c)));
        
        cslaser.median(1,c) = nanmedian(cslaser.data(expIdx,c));
        temp = cslaser.data(expIdx,c);
        nonantemp = ~isnan(temp);
        cslaser.mad(1,c) = mad(temp(nonantemp),1);
        cslaser.n(1,c) = sum(~isnan(cslaser.data(expIdx,c)));
        
        cslaserus.median(1,c) = nanmean(cslaserus.data(expIdx,c));
        temp = cslaserus.data(expIdx,c);
        nonantemp = ~isnan(temp);
        cslaserus.mad(1,c) =mad(temp(nonantemp),1);
        cslaserus.n(1,c) = sum(~isnan(cslaserus.data(expIdx,c)));
    end
   
    
    %% plot
    handles.during = figure;
    a = errorbar([1:18], csuslaser.median(1,:), csuslaser.mad(1,:), '.');
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
    
    handles.afterlate = figure;
    b = errorbar([1:18], cslaser.median, cslaser.mad, '.');
    hold on
    c = errorbar([1:18], cslaserus.median, cslaserus.mad, '.');
    e = plot([2.5 2.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    f = plot([12.5 12.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [0 0 0]);
    xlim(xrange)
    ylim(yrange)
    tempstring = strcat(label, 'expt only: median across mice +/- med abs dev');
    title(tempstring)
    legend('CS + laser extinction', 'CS + laser alt US alone extinction', 'Location', 'NorthOutside')
    xlabel('session')
    ylabel(label)
    
elseif strcmpi(type, 'median')
    csuslaser.med = nan(1,18);
    csuslaser.n = nan(1,18);
    cslaser.med = nan(1,18);
    cslaser.n = nan(1,18);
    cslaserus.med = nan(1,18);
    cslaserus.n = nan(1,18);
    early.med = nan(1,18);
    early.n = nan(1,18);
    for c = 1:18 % go through each column in the plotData structure and get experimental animal data
        % this part of the code depends on there being exactly 4 animals in each
        % condition
        tempquants = quantile(csuslaser.data(expIdx,c), 3);
        csuslaser.med(1,c) = tempquants(2);
        csuslaser.quantile1(1,c) = tempquants(1);
        csuslaser.quantile3(1,c) = tempquants(3);
        csuslaser.n(1,c) = sum(~isnan(csuslaser.data(expIdx,c)));
        
        tempquants = quantile(cslaser.data(expIdx,c), 3);
        cslaser.med(1,c) = tempquants(2);
        cslaser.quantile1(1,c) = tempquants(1);
        cslaser.quantile3(1,c) = tempquants(3);
        cslaser.n(1,c) = sum(~isnan(cslaser.data(expIdx,c)));
        
        tempquants = quantile(cslaserus.data(expIdx,c), 3);
        cslaserus.med(1,c) = tempquants(2);
        cslaserus.quantile1(1,c) = tempquants(1);
        cslaserus.quantile3(1,c) = tempquants(3);
        cslaserus.n(1,c) = sum(~isnan(cslaserus.data(expIdx,c)));
        
        
        tempquants = quantile(unpext.data(contIdx,c), 3);
        unpext.med(1,c) = tempquants(2);
        unpext.quantile1(1,c) = tempquants(1);
        unpext.quantile3(1,c) = tempquants(3);
        unpext.n(1,c) = sum(~isnan(unpext.data(expIdx,c)));
    end
    
    %% plot
    handles.during = figure;
    a = plot([1:18], csuslaser.med(1,:), '.', 'Color', [1 0 1], 'MarkerSize', 20);
    hold on
    for i = 1:18
        abars = plot([i i], [csuslaser.quantile1(1,i),csuslaser.quantile3(1,i)], ...
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
    
    
    handles.afterlate = figure;
    a = plot([1:18], cslaser.med(1,:), '.', 'Color', [1 0 1], 'MarkerSize', 20);
    hold on
    for i = 1:18
        abars = plot([i i], [cslaser.quantile1(1,i),cslaser.quantile3(1,i)], ...
            'Color', [1 0 1]);
    end
    
    b = plot([1:18], cslaserus.med(1,:), '.', 'Color', [0 1 1], 'MarkerSize', 20);
    for i = 1:18
        bbars = plot([i i], [cslaserus.quantile1(1,i),cslaserus.quantile3(1,i)], ...
            'Color', [0 1 1]);
    end
    
    c = plot([1:18], unpext.med(1,:), '.', 'Color', [0 1 0], 'MarkerSize', 20);
    for i = 1:18
        cbars = plot([i i], [unpext.quantile1(1,i),unpext.quantile3(1,i)], ...
            'Color', [0 1 0]);
    end
    
    e = plot([2.5 2.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [1 1 1]);
    f = plot([12.5 12.5], [0 yrange(2)], 'LineStyle', '--', 'Color', [1 1 1]);
    xlim(xrange)
    ylim(yrange)
    tempstring = strcat(label, 'expt only: median across mice +/- quartiles');
    title(tempstring)
    legend([a, b, c],'CS + laser extinction', 'CS + laser alt US alone extinction',...
        'WT unpaired extinction', 'Location', 'NorthOutside')
    xlabel('session')
    ylabel(label)
end
end