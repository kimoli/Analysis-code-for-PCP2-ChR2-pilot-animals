function [output, spontrecovdata] = getDayData_PCP2ChR2Pilot(data, timeVector, mouseinfo)

mouseNames = unique(data.mouse);
mousenum = length(mouseNames);

output = setUpOutput_PCP2ChR2();
spontrecovdata = {};
 
for m = 1:mousenum
    thisMouse = mouseNames(m,1);
    disp(thisMouse)
    daylist = unique(data.date(strcmpi(data.mouse, thisMouse),1));
    
    % have to make this loop because for some reason having trouble
    % interacting with the values in mouseinfo.name in a line like 
    %       " crcrit = mouseinfo(strcmpi(mouseinfo.name,
    %       thisMouse),1).crcrit;"
    crcrit = [];
    for n = 1:length(mouseinfo)
        if strcmpi(mouseinfo(n,1).name, thisMouse)
            crcrit = mouseinfo(n,1).crcrit;
        end
    end   
    
   
    for d = 1:length(daylist)
        if d==1
            % this will be the day with the tone amplitude adjustments on
            % CS-only trials
            pairedTrials = find(strcmpi(data.mouse, thisMouse) & data.date == daylist(d) & ...
               data.c_usdur>0 & data.type==1); % want to exclude the CS alone trials where the CS intensity can change
        else
            pairedTrials = find(strcmpi(data.mouse, thisMouse) & data.date == daylist(d) & ...
                data.type==1 & data.c_csdur > 0);
        end
       
        if length(data.noCRTrialSelected(pairedTrials))~=length(pairedTrials)
            disp('PROBLEM')
            pause
        end
        [output, blockedCRadjamp] = pullData_PCP2ChR2(data.eyelidpos, data.noCRTrialSelected(pairedTrials), data.c_usdur,...
            pairedTrials, timeVector, ...
            crcrit, output, thisMouse, daylist(d));
        tempdays = ones(length(blockedCRadjamp),1)*daylist(d);
        tempcell = {};
        tempcell(1:length(blockedCRadjamp),1) = {thisMouse};
        addme = [num2cell(blockedCRadjamp),num2cell(tempdays),tempcell];
        spontrecovdata = [spontrecovdata;addme];
    end
end

end