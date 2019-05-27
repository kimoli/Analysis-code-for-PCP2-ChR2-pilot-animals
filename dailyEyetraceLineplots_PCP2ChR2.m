function [] = dailyEyetraceLineplots_PCP2ChR2(output, mouse, makeFig)
mouserow = find(strcmpi(output.mouse, mouse));
if makeFig
    colordef white
    figure
end
hold on
leglabs = {};
coloroptions = [...
    0 0 1;...
    0.35 0 1;...
    0.65 0 1;...
    1 0 1;...
    1 0 0.65;...
    1 0 0.35;...
    1 0 0];
iter = 1;
for c = 1:size(output.blockedEyelidpos,2)
    if ~isempty(output.blockedEyelidpos{mouserow,c})
        eyetrace = output.blockedEyelidpos{mouserow,c};
        plot(eyetrace, 'Color', coloroptions(iter,:))
        iter = iter+1;
        leglabs{1,end+1} = num2str(c);
    end
end
legend(leglabs)
end