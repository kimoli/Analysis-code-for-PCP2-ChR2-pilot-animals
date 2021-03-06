function [daydiv] = blockEyetraceHeatmaps_PCP2ChR2(output, mouse, windows)
mouserow = find(strcmpi(output.mouse, mouse));
colordef white
figure
mapme = [];
firstTrialIndices = [];
for c = 1:size(output.blockedEyelidpos,2)
    if ~isempty(output.blockedEyelidpos{mouserow,c})
        tempEyetraces = output.blockedEyelidpos{mouserow,c};
        if size(tempEyetraces,2)<340
            addnans = 340 - size(tempEyetraces,2);
            tempEyetraces = [tempEyetraces, nan(size(tempEyetraces,1),addnans)];
        end
        firstTrialIdx = [1;zeros(size(tempEyetraces,1)-1,1)];
        mapme = [mapme; tempEyetraces];
        firstTrialIndices = [firstTrialIndices; firstTrialIdx];
    end
end
daydiv = find(firstTrialIndices);
for s = 1:size(windows,1)
    subplot(1,size(windows,1),s)
    imagesc(mapme(:,windows(s,1):windows(s,2)))
    hold on
    for d = 2:length(daydiv)
        plot([0 340], [daydiv(d,1)-0.5 daydiv(d,1)-0.5], 'Color', [1 1 1], 'LineWidth',1)
    end
    caxis([0 1])
end

end