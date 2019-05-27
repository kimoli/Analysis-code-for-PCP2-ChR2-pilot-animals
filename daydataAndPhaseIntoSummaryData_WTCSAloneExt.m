function [output] = daydataAndPhaseIntoSummaryData_WTCSAloneExt(datespreadsheet_headers,...
    datespreadsheet_dates, daydat, phase, outputMouseIdx)

[rows cols] = size(datespreadsheet_dates);
output.FEC180.data = [];
output.FEC220.data = [];
output.mouse = [];
output.crprob.data = [];


% the different rows of the date spreadsheet specify the different days of
% each phase. that is, there is one row for the "during" phase of the
% manipulation for each animal, one row for the "after" phase, etc. each
% column corresponds to a different day of the phase specified in the row
% label in column 2 of the spreadsheet
idx = find(strcmpi(phase, datespreadsheet_headers(:,2)));
for i = 1:length(idx)
    r = idx(i);
    thisMouse = datespreadsheet_dates{r,1};
    mousePos = find(strcmp(outputMouseIdx, thisMouse));
    output.mouse{mousePos, 1} = thisMouse;
    for c = 3:cols % start at col 3 because rows 1-2 is just headers
        thisDay = datespreadsheet_dates{r,c};
        
        if ~ischar(thisDay) && ~isnan(thisDay) % skip days without numbers
            % for these values, only include trials that have a CS
            FEC220 = daydat.FEC220(daydat.date(:,1)==thisDay ...
                & strcmpi(daydat.mouse(:,1), thisMouse), 1); 
            FEC180 = daydat.FEC180(daydat.date(:,1)==thisDay ...
                & strcmpi(daydat.mouse(:,1), thisMouse), 1);
            crprob = daydat.CRProb(daydat.date(:,1)==thisDay ...
                & strcmpi(daydat.mouse(:,1),thisMouse), 1);
            output.FEC180.data(mousePos,c-2) = FEC180;
            output.FEC220.data(mousePos,c-2) = FEC220;
            output.crprob.data(mousePos, c-2) = crprob;
    
            clear FEC220 FEC180 startleamp slramp rbamp
        else
            output.FEC180.data(mousePos,c-2) = NaN;
            output.FEC220.data(mousePos,c-2) = NaN;
            output.crprob.data(mousePos, c-2) = NaN;
        end
    end
    clear thisMouse
end

output.mouse{9,1} = 'median';
output.mouse{10,1} = '1st quantile';
output.mouse{11,1} = '3rd quantile';
for i = 1:size(output.FEC180.data,2)
    tempquants = quantile(output.FEC180.data(1:8,i), 3);
    output.FEC180.data(9,i) = tempquants(2);
    if sum(~isnan(output.FEC180.data(5:8,i)))>2
        output.FEC180.data(10,i) = tempquants(1);
        output.FEC180.data(11,i) = tempquants(3);
    else
        output.FEC180.data(10,i) = NaN;
        output.FEC180.data(11,i) = NaN;
    end
    
    tempquants = quantile(output.FEC220.data(1:8,i), 3);
    output.FEC220.data(9,i) = tempquants(2);
    if sum(~isnan(output.FEC220.data(5:8,i)))>2
        output.FEC220.data(10,i) = tempquants(1);
        output.FEC220.data(11,i) = tempquants(3);
    else
        output.FEC220.data(10,i) = NaN;
        output.FEC220.data(11,i) = NaN;
    end
    
    tempquants = quantile(output.crprob.data(1:8,i), 3);
    output.crprob.data(9,i) = tempquants(2);
    if sum(~isnan(output.crprob.data(5:8,i)))>2
        output.crprob.data(10,i) = tempquants(1);
        output.crprob.data(11,i) = tempquants(3);
    else
        output.crprob.data(10,i) = NaN;
        output.crprob.data(11,i) = NaN;
    end
end


end