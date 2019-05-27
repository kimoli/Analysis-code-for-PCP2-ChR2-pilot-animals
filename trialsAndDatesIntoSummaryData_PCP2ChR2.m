function [output] = trialsAndDatesIntoSummaryData_PCP2ChR2(datespreadsheet_headers,...
    datespreadsheet_dates, dayData, phase, outputMouseIdx)
numMice = length(outputMouseIdx);

[rows cols] = size(datespreadsheet_dates);
output.crprob.data = nan(numMice,18);
output.cradjamp.data = nan(numMice,18);
output.prepuffamp.data = nan(numMice,18);
output.uramp.data = nan(numMice,18);
output.missuramp.data = nan(numMice,18);
output.hituramp.data = nan(numMice,18);
output.urint.data=nan(numMice,18);
output.missurint.data=nan(numMice,18);
output.hiturint.data=nan(numMice,18);
output.mouse = {};
output.crint.data = nan(numMice,18);
output.hitcrint.data = nan(numMice,18);
output.startleamp.data = nan(numMice,18);


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
            crprob = dayData.CRProb(dayData.date(:,1)==thisDay & ...
                strcmpi(dayData.mouse(:,1), thisMouse),1);
            missuramp = dayData.meanMissURAmp(dayData.date(:,1)==thisDay &...
                strcmpi(dayData.mouse(:,1), thisMouse),1);
            hituramp = dayData.meanHitURAmp(dayData.date(:,1)==thisDay & ...
                strcmpi(dayData.mouse(:,1), thisMouse),1);
            missurint = dayData.meanMissURIntegral(dayData.date(:,1)==thisDay...
                & strcmpi(dayData.mouse(:,1), thisMouse),1);
            hiturint = dayData.meanHitURIntegral(dayData.date(:,1)==thisDay ...
                & strcmpi(dayData.mouse(:,1), thisMouse),1);  
            prepuffamp = dayData.meanPrepuffAmp(dayData.date(:,1)==thisDay ...
                & strcmpi(dayData.mouse(:,1), thisMouse),1); 
            startleamp = dayData.meanAStartleAmp(dayData.date(:,1)==thisDay ...
                & strcmpi(dayData.mouse(:,1), thisMouse),1); 
            
            cradjampAll = dayData.meanCRAdjAmp(dayData.date(:,1)==thisDay &...
                strcmpi(dayData.mouse(:,1), thisMouse),1);
            cradjampHit = dayData.hitCRAdjAmp(dayData.date(:,1)==thisDay &...
                strcmpi(dayData.mouse(:,1), thisMouse),1);
            uramp = dayData.meanURAmp(dayData.date(:,1)==thisDay & ...
                strcmpi(dayData.mouse(:,1), thisMouse),1);
            urint = dayData.meanURIntegral(dayData.date(:,1)==thisDay &...
                strcmpi(dayData.mouse(:,1), thisMouse),1);
            crint = dayData.meancrintegral(dayData.date(:,1)==thisDay &...
                strcmpi(dayData.mouse(:,1), thisMouse),1);
            hitcrint = dayData.meanhitcrintegral(dayData.date(:,1)==thisDay &...
                strcmpi(dayData.mouse(:,1), thisMouse),1);
            
            output.crprob.data(mousePos,c-2) = crprob;
            output.cradjamp.data(mousePos,c-2) = cradjampAll;
            output.prepuffamp.data(mousePos,c-2) = prepuffamp;
            output.cradjampHit.data(mousePos,c-2) = cradjampHit;
            output.uramp.data(mousePos,c-2)=uramp;
            output.missuramp.data(mousePos,c-2)=missuramp;
            output.hituramp.data(mousePos,c-2)=hituramp;
            output.missurint.data(mousePos,c-2)=missurint;
            output.hiturint.data(mousePos,c-2)=hiturint;
            output.urint.data(mousePos,c-2)=urint;
            output.crint.data(mousePos, c-2)=crint;
            output.hitcrint.data(mousePos, c-2)=hitcrint;
            output.startleamp.data(mousePos, c-2) = startleamp;
    
            clear crprob cradjampAll uramp thisDay cradjampEarly cradjampLate...
                uring crint missuramp hituramp missurint hiturint
        end
    end
    clear thisMouse
end
