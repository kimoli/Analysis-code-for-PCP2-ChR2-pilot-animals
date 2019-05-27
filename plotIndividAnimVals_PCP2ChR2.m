function plotIndividAnimVals_PCP2ChR2(output, mouse, titlestring, excl20)
mouserow = find(strcmpi(output.mouse, mouse));
colordef white
figure
fec180ptspltd = 0;
fec230ptspltd = 0;
startleptspltd = 0;
slrptspltd = 0;
rbptspltd = 0;
for c = 1:size(output.FEC180.data,2)
    if c<3 || c>12
       colorarr = [0 0 1];
    else
       colorarr = [1 0 0];
    end
    
    subplot(5,1,1)
    plotme = output.FEC180.data{mouserow, c};
    if excl20 && c == 12 % need to omit last 20 trials on this day because of extra manipulation did in this mouse
        plotme = plotme(1:end-20);
    end
    scatter([fec180ptspltd+1:fec180ptspltd+length(plotme)], plotme, 3, ...
        'MarkerEdgeColor', colorarr, 'MarkerFaceColor', colorarr)
    fec180ptspltd = fec180ptspltd + length(plotme);
    hold on
    plot([fec180ptspltd+0.5 fec180ptspltd+0.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    
    subplot(5,1,2)
    plotme = output.FEC230.data{mouserow, c};
    if excl20 && c == 12 % need to omit last 20 trials on this day because of extra manipulation did in this mouse
        plotme = plotme(1:end-20);
    end
    scatter([fec230ptspltd+1:fec230ptspltd+length(plotme)], plotme, 3, ...
        'MarkerEdgeColor', colorarr, 'MarkerFaceColor', colorarr)
    fec230ptspltd = fec230ptspltd + length(plotme);
    hold on
    plot([fec230ptspltd+0.5 fec230ptspltd+0.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    
    subplot(5,1,3)
    plotme = output.startleamp.data{mouserow, c};
    if excl20 && c == 12 % need to omit last 20 trials on this day because of extra manipulation did in this mouse
        plotme = plotme(1:end-20);
    end
    scatter([startleptspltd+1:startleptspltd+length(plotme)], plotme, 3, ...
        'MarkerEdgeColor', colorarr, 'MarkerFaceColor', colorarr)
    startleptspltd = startleptspltd + length(plotme);
    hold on
    plot([startleptspltd+0.5 startleptspltd+0.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    
    subplot(5,1,4)
    plotme = output.slramp.data{mouserow, c};
    if excl20 && c == 12 % need to omit last 20 trials on this day because of extra manipulation did in this mouse
        plotme = plotme(1:end-20);
    end
    scatter([slrptspltd+1:slrptspltd+length(plotme)], plotme, 3, ...
        'MarkerEdgeColor', colorarr, 'MarkerFaceColor', colorarr)
    slrptspltd = slrptspltd + length(plotme);
    hold on
    plot([slrptspltd+0.5 slrptspltd+0.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    
    subplot(5,1,5)
    plotme = output.rbamp.data{mouserow, c};
    if excl20 && c == 12 % need to omit last 20 trials on this day because of extra manipulation did in this mouse
        plotme = plotme(1:end-20);
    end
    scatter([rbptspltd+1:rbptspltd+length(plotme)], plotme, 3,...
        'MarkerEdgeColor', colorarr, 'MarkerFaceColor', colorarr)
    rbptspltd = rbptspltd + length(plotme);
    if c<=2 && isempty(plotme)
        rbptspltd = fec180ptspltd;
    end
    hold on
    plot([rbptspltd+0.5 rbptspltd+0.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
end
subplot(5,1,1)
plot([0 fec180ptspltd+1], [0.1 0.1], 'LineStyle', '--', 'Color', [0 0 0])
xlim([0 fec180ptspltd+1])
ylabel('FEC 180 ms')
ylim([0 1])
title(titlestring)
subplot(5,1,2)
plot([0 fec180ptspltd+1], [0.1 0.1], 'LineStyle', '--', 'Color', [0 0 0])
xlim([0 fec230ptspltd+1])
ylabel('FEC 230 ms')
ylim([0 1])
subplot(5,1,3)
plot([0 fec180ptspltd+1], [0.1 0.1], 'LineStyle', '--', 'Color', [0 0 0])
xlim([0 startleptspltd+1])
ylabel('startle FEC')
subplot(5,1,4)
plot([0 fec180ptspltd+1], [0.1 0.1], 'LineStyle', '--', 'Color', [0 0 0])
xlim([0 slrptspltd+1])
ylabel('slr FEC')
subplot(5,1,5)
plot([0 fec180ptspltd+1], [0.1 0.1], 'LineStyle', '--', 'Color', [0 0 0])
xlim([0 rbptspltd+1])
ylabel('RB FEC')
xlabel('trials')
ylim([0 1])

end