function plotIndividAnimVals_PCP2ChR2(output, mouse, titlestring, excl20)
mouserow = find(strcmpi(output.mouse, mouse));
colordef white
figure
fec180ptspltd = 0;
fec220ptspltd = 0;
startleptspltd = 0;
slrptspltd = 0;
rbptspltd = 0;
for c = 1:size(output.FEC180.data,2)
    if c<3 || c>12
       colorarr = [0 0 1];
    else
       colorarr = [1 0 0];
    end
    
    subplot(2,1,1)
    plotme = output.FEC180.data{mouserow, c};
    if excl20 && c == 12 % need to omit last 20 trials on this day because of extra manipulation did in this mouse
        plotme = plotme(1:end-20);
    end
    scatter([fec180ptspltd+1:fec180ptspltd+length(plotme)], plotme, 3, ...
        'MarkerEdgeColor', colorarr, 'MarkerFaceColor', colorarr)
    fec180ptspltd = fec180ptspltd + length(plotme);
    hold on
    plot([fec180ptspltd+0.5 fec180ptspltd+0.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    
    subplot(2,1,2)
    plotme = output.FEC220.data{mouserow, c};
    if excl20 && c == 12 % need to omit last 20 trials on this day because of extra manipulation did in this mouse
        plotme = plotme(1:end-20);
    end
    scatter([fec220ptspltd+1:fec220ptspltd+length(plotme)], plotme, 3, ...
        'MarkerEdgeColor', colorarr, 'MarkerFaceColor', colorarr)
    fec220ptspltd = fec220ptspltd + length(plotme);
    hold on
    plot([fec220ptspltd+0.5 fec220ptspltd+0.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
    
end
subplot(2,1,1)
plot([0 fec180ptspltd+1], [0.1 0.1], 'LineStyle', '--', 'Color', [0 0 0])
xlim([0 fec180ptspltd+1])
ylabel('FEC 180 ms')
ylim([0 1])
title(titlestring)
subplot(2,1,2)
plot([0 fec180ptspltd+1], [0.1 0.1], 'LineStyle', '--', 'Color', [0 0 0])
xlim([0 fec220ptspltd+1])
ylabel('FEC 220 ms')
ylim([0 1])

end