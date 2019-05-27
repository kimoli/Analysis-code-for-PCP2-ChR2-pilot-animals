function [axhandles, fighandles] = plotGroupMedianVals_WTCSAloneExt(txt, raw, rbdatDayData, phase, plotDataAnimals)

[output] = daydataAndPhaseIntoSummaryData_WTCSAloneExt(txt,...
    raw, rbdatDayData, phase, plotDataAnimals);
fighandles.a = figure;
axhandles.a = subplot(1,1,1);
scatter(1:size(output.FEC180.data,2),output.FEC180.data(9,:), 10, 'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [0 0 1])
hold on
scatter(1:size(output.FEC220.data,2),output.FEC220.data(9,:), 10, 'MarkerFaceColor', [1 0.5 0], 'MarkerEdgeColor', [1 0.5 0])
legend('FEC 180', 'FEC 220', 'Location', 'NorthWest')
for i = 1:size(output.FEC180.data,2)
    plot([i, i], [output.FEC180.data(10,i), output.FEC180.data(11,i)], 'Color', [0 0 1])
    plot([i, i], [output.FEC220.data(10,i), output.FEC220.data(11,i)], 'Color', [1 0.5 0])
end
plot([2.5 2.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([12.5 12.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
ylabel('FEC - baseline')
xlabel('session')

fighandles.b = figure;
axhandles.c = subplot(1,1,1);
scatter(1:size(output.crprob.data,2),output.crprob.data(9,:), 10, 'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [0 0 1])
hold on
legend('CR Prob', 'Location', 'North')
for i = 1:size(output.FEC180.data,2)
    plot([i, i], [output.crprob.data(10,i), output.crprob.data(11,i)], 'Color', [0 0 1])
end
plot([2.5 2.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([12.5 12.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
ylabel('Probability')
xlabel('session')
end