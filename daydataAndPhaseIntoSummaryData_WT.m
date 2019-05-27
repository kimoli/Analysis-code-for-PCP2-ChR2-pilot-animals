function [output] = daydataAndPhaseIntoSummaryData_WT(datespreadsheet_headers,...
    datespreadsheet_dates, daydat, phase, outputMouseIdx)

[rows cols] = size(datespreadsheet_dates);
output.FEC180.data = [];
output.FEC230.data = [];
output.mouse = [];
output.slramp.data = [];
output.rbamp.data = [];
output.rbprob.data = [];
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
            FEC230 = daydat.FEC230(daydat.date(:,1)==thisDay ...
                & strcmpi(daydat.mouse(:,1), thisMouse), 1); 
            FEC180 = daydat.FEC180(daydat.date(:,1)==thisDay ...
                & strcmpi(daydat.mouse(:,1), thisMouse), 1); 
            slramp = daydat.SLRAmp(daydat.date(:,1)==thisDay ...
                & strcmpi(daydat.mouse(:,1),thisMouse), 1);
            rbamp = daydat.RBAmp(daydat.date(:,1)==thisDay ...
                & strcmpi(daydat.mouse(:,1),thisMouse), 1);
            rbprob = daydat.RBProb(daydat.date(:,1)==thisDay ...
                & strcmpi(daydat.mouse(:,1),thisMouse), 1);
            crprob = daydat.CRProb(daydat.date(:,1)==thisDay ...
                & strcmpi(daydat.mouse(:,1),thisMouse), 1);

                        
            output.FEC180.data(mousePos,c-2) = FEC180;
            output.FEC230.data(mousePos,c-2) = FEC230;
            output.slramp.data(mousePos, c-2) = slramp;
            output.rbamp.data(mousePos, c-2) = rbamp;
            output.rbprob.data(mousePos, c-2) = rbprob;
            output.crprob.data(mousePos, c-2) = crprob;
    
            clear FEC230 FEC180 startleamp slramp rbamp
        else
            output.FEC180.data(mousePos,c-2) = NaN;
            output.FEC230.data(mousePos,c-2) = NaN;
            output.slramp.data(mousePos, c-2) = NaN;
            output.rbamp.data(mousePos, c-2) = NaN;
            output.rbprob.data(mousePos, c-2) = NaN;
            output.crprob.data(mousePos, c-2) = NaN;
        end
    end
    clear thisMouse
end

output.mouse{9,1} = 'median';
output.mouse{10,1} = '1st quantile';
output.mouse{11,1} = '3rd quantile';
for i = 1:size(output.FEC180.data,2)
    tempquants = quantile(output.FEC180.data(5:8,i), 3);
    output.FEC180.data(9,i) = tempquants(2);
    if sum(~isnan(output.FEC180.data(5:8,i)))>2
        output.FEC180.data(10,i) = tempquants(1);
        output.FEC180.data(11,i) = tempquants(3);
    else
        output.FEC180.data(10,i) = NaN;
        output.FEC180.data(11,i) = NaN;
    end
    
    tempquants = quantile(output.FEC230.data(5:8,i), 3);
    output.FEC230.data(9,i) = tempquants(2);
    if sum(~isnan(output.FEC230.data(5:8,i)))>2
        output.FEC230.data(10,i) = tempquants(1);
        output.FEC230.data(11,i) = tempquants(3);
    else
        output.FEC230.data(10,i) = NaN;
        output.FEC230.data(11,i) = NaN;
    end
    
    tempquants = quantile(output.slramp.data(5:8,i), 3);
    output.slramp.data(9,i) = tempquants(2);
    if sum(~isnan(output.slramp.data(5:8,i)))>2
        output.slramp.data(10,i) = tempquants(1);
        output.slramp.data(11,i) = tempquants(3);
    else
        output.slramp.data(10,i) = NaN;
        output.slramp.data(11,i) = NaN;
    end
    
    tempquants = quantile(output.rbamp.data(5:8,i), 3);
    if sum(~isnan(output.rbamp.data(5:8,i)))>0
        output.rbamp.data(9,i) = tempquants(2);
    else
        output.rbamp.data(9,i) = NaN;
    end
    if sum(~isnan(output.rbamp.data(5:8,i)))>2
        output.rbamp.data(10,i) = tempquants(1);
        output.rbamp.data(11,i) = tempquants(3);
    else
        output.rbamp.data(10,i) = NaN;
        output.rbamp.data(11,i) = NaN;
    end
    
    tempquants = quantile(output.rbprob.data(5:8,i), 3);
    if sum(~isnan(output.rbprob.data(5:8,i)))>0
        output.rbprob.data(9,i) = tempquants(2);
    else
        output.rbprob.data(9,i) = NaN;
    end
    if sum(~isnan(output.rbprob.data(5:8,i)))>2
        output.rbprob.data(10,i) = tempquants(1);
        output.rbprob.data(11,i) = tempquants(3);
    else
        output.rbprob.data(10,i) = NaN;
        output.rbprob.data(11,i) = NaN;
    end
    
    tempquants = quantile(output.crprob.data(5:8,i), 3);
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