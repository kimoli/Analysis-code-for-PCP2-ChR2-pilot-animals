function [output] = trialsAndDatesIntoSummaryData_individTrials_WTCSAloneExt(datespreadsheet_headers,...
    datespreadsheet_dates, dat, phase, outputMouseIdx)
numMice = length(outputMouseIdx);

[rows cols] = size(datespreadsheet_dates);
output.FEC180.data = {};
output.FEC220.data = {};
output.mouse = {};
output.startleamp.data = {};
output.slramp.data = {};
output.rbamp.data = {};


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
            FEC220 = dat.FEC220(dat.date(:,1)==thisDay ...
                & strcmpi(dat.mouse(:,1), thisMouse) & dat.c_csdur>0, 1); 
            FEC180 = dat.FEC180(dat.date(:,1)==thisDay ...
                & strcmpi(dat.mouse(:,1), thisMouse) & dat.c_csdur>0, 1); 
            output.FEC180.data{mousePos,c-2} = FEC180';
            output.FEC220.data{mousePos,c-2} = FEC220';
            
            if isfield(dat, 'startleamp')
                startleamp = dat.startleamp(dat.date(:,1)==thisDay ...
                    & strcmpi(dat.mouse(:,1), thisMouse) & dat.c_csdur>0, 1);
                slramp = dat.slramp(dat.date(:,1)==thisDay ...
                    & strcmpi(dat.mouse(:,1),thisMouse) & dat.c_csdur>0, 1);
                
                % for these values, only include trials that have a laser
                rbamp = dat.rbamp(dat.date(:,1)==thisDay ...
                    & strcmpi(dat.mouse(:,1),thisMouse) & dat.laserDur>0, 1);
                
                output.startleamp.data{mousePos, c-2} = startleamp';
                output.slramp.data{mousePos, c-2} = slramp';
                output.rbamp.data{mousePos, c-2} = rbamp';
            end
    
            clear FEC220 FEC180 startleamp slramp rbamp
        end
    end
    clear thisMouse
end
