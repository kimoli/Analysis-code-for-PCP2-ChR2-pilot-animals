function [output] = trialsAndDatesIntoBlockedEyetraces_PCP2ChR2(datespreadsheet_headers,...
    datespreadsheet_dates, dat, phase, outputMouseIdx, blockSize, includeWhat)

[~, cols] = size(datespreadsheet_dates);
output.blockedEyelidpos = {};


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
            if strcmpi(includeWhat, 'CS trials')
                idx2 = dat.date(:,1)==thisDay ...
                    & strcmpi(dat.mouse(:,1), thisMouse) & dat.c_csdur>0;
            elseif strcmpi(includeWhat, 'CS no laser')
                idx2 = dat.date(:,1)==thisDay & strcmpi(dat.mouse(:,1), thisMouse)...
                    & dat.c_csdur>0 & dat.laserDur==0;
            elseif strcmpi(includeWhat, 'US only')
                idx2 = dat.date(:,1)==thisDay & strcmpi(dat.mouse(:,1), thisMouse)...
                    & dat.c_csdur==0 & dat.c_usdur > 0;
            elseif strcmpi(includeWhat, 'Laser only')
                idx2 = dat.date(:,1)==thisDay  & strcmpi(dat.mouse(:,1), thisMouse)...
                    & dat.c_csdur==0 & dat.laserDur > 0;
            elseif strcmpi(includeWhat, 'CS + laser')
                idx2 = dat.date(:,1)==thisDay  & strcmpi(dat.mouse(:,1), thisMouse)...
                    & dat.c_csdur > 0 & dat.laserDur > 0;
            end
            eyelidpos = dat.eyelidpos(idx2, :);
            adjme = dat.baseline(idx2, :);
            subtractme = adjme * ones(1, size(eyelidpos,2));
            eyelidpos = eyelidpos - subtractme;
            
            blockedEyelidpos = [];
            for blockBeg = 1:blockSize:size(eyelidpos,1)
                if blockBeg + (blockSize*2) <= size(eyelidpos,1)
                    blockEnd = blockSize + blockBeg - 1;
                else
                    blockEnd = size(eyelidpos,1);
                end
                temp = nanmean(eyelidpos(blockBeg:blockEnd,:));
                blockedEyelidpos = [blockedEyelidpos;temp];
                if blockEnd == size(eyelidpos,1) % for cases where blockEnd gets set by experimenter
                    break
                end
            end
            
            output.blockedEyelidpos{mousePos,c-2} = blockedEyelidpos;
    
            clear blockedEyelidpos
        end
    end
    clear thisMouse
end
