function [axhandles, fighandles] = plotGroupMedianVals_WT(txt, raw, rbdatDayData, phase, plotDataAnimals)

[output] = daydataAndPhaseIntoSummaryData_WT(txt,...
    raw, rbdatDayData, phase, plotDataAnimals);
fighandles.a = figure;
axhandles.a = subplot(1,2,1);
scatter(1:size(output.FEC180.data,2),output.FEC180.data(9,:), 10, 'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [0 0 1])
hold on
scatter(1:size(output.FEC230.data,2),output.FEC230.data(9,:), 10, 'MarkerFaceColor', [1 0.5 0], 'MarkerEdgeColor', [1 0.5 0])
legend('FEC 180', 'FEC 230', 'Location', 'NorthWest')
for i = 1:size(output.FEC180.data,2)
    plot([i, i], [output.FEC180.data(10,i), output.FEC180.data(11,i)], 'Color', [0 0 1])
    plot([i, i], [output.FEC230.data(10,i), output.FEC230.data(11,i)], 'Color', [1 0.5 0])
end
plot([2.5 2.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([12.5 12.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
ylabel('FEC - baseline')
xlabel('session')
axhandles.b = subplot(1,2,2);
hold on
scatter(1:size(output.rbamp.data,2),output.rbamp.data(9,:), 10, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 0 1])
scatter(1:size(output.slramp.data,2),output.slramp.data(9,:), 10, 'MarkerFaceColor', [0 1 1], 'MarkerEdgeColor', [0 1 1])
legend('RB amp', 'SLR amp', 'Location', 'North')
for i = 1:size(output.FEC180.data,2)
    plot([i, i], [output.rbamp.data(10,i), output.rbamp.data(11,i)], 'Color', [1 0 1])
    plot([i, i], [output.slramp.data(10,i), output.slramp.data(11,i)], 'Color', [0 1 1])
end
plot([2.5 2.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([12.5 12.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
xlabel('session')

fighandles.b = figure;
axhandles.c = subplot(1,1,1);
scatter(1:size(output.crprob.data,2),output.crprob.data(9,:), 10, 'MarkerFaceColor', [0 0 1], 'MarkerEdgeColor', [0 0 1])
hold on
scatter(1:size(output.rbprob.data,2),output.rbprob.data(9,:), 10, 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0])
legend('CR Prob', 'RB Prob', 'Location', 'North')
for i = 1:size(output.FEC180.data,2)
    plot([i, i], [output.crprob.data(10,i), output.crprob.data(11,i)], 'Color', [0 0 1])
    plot([i, i], [output.rbprob.data(10,i), output.rbprob.data(11,i)], 'Color', [1 0 0])
end
plot([2.5 2.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
plot([12.5 12.5], [0 1], 'LineStyle', ':', 'Color', [0 0 0])
ylabel('Probability')
xlabel('session')
end