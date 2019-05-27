clear all
close all
machine = 'ALBUS';

if strcmpi(machine, 'ALBUS')
    basedir = 'L:\users\okim\behavior';
    savedir = 'C:\olivia\data\concat beh dat';
elseif strcmpi(machine, 'OREK')
    basedir = 'E:\data\behavior';
    savedir = 'E:\data\concat beh dat';
end

cd(basedir)
%mice = dir('OK*');
mice(1,1).name='OK001';
mice(2,1).name='OK002';
mice(3,1).name='OK003';
mice(4,1).name='OK004';
mice(5,1).name='OK005';
mice(6,1).name='OK006';
mice(7,1).name='OK007';
mice(8,1).name='OK008';


[hardware{1:8,1}] = deal('arduino');

rbdat.eyelidpos = [];
rbdat.trialnum = [];
rbdat.baseline = [];
rbdat.baselineMvt = [];
rbdat.c_isi = [];
rbdat.c_csnum = [];
rbdat.c_csdur = [];
rbdat.c_usnum = [];
rbdat.c_usdur = [];
rbdat.type = []; % for ease of use later, let 1 = conditioning trials and 0=other
rbdat.tDay = [];
rbdat.group = []; % 1 is experimental and 2 is control
rbdat.date = [];
rbdat.mouse = {};
rbdat.eyelidposOrigNorm = [];

timeVector = [];

for m = 1:length(mice);
    
    mouse = mice(m,1).name;
    goHere = strcat(basedir, '\', mouse);
    cd(goHere)
    days = dir('1*');
    tDay = 1;
    increment = 0;
    
    for d = 1:length(days)
        thisDay = strcat(goHere,'\',days(d).name);
        cd(thisDay)
        pullData = 0;
        trialsManuallyProcessed = 0;
        if exist('newTrialdata.mat', 'file')==2
            load('newTrialdata.mat')
            pullData = 1;
            trialsManuallyProcessed = 1;
        elseif exist('trialdata.mat', 'file')==2
            load('trialdata.mat')
            pullData = 1;
            trialsManuallyProcessed = 0;
        end
        
        noCRTrialsSelected = 0;
        noCRTrialFilename = strcat(mouse,'_',days(d).name,'_noCRTrials.mat');
        if exist(noCRTrialFilename, 'file') == 2
            noCRTrialsSelected = 1;
            load(noCRTrialFilename)
        end
        
        if pullData
            if sum(trials.c_usdur)>0
                increment = 1;
            end
            
            if increment % training has begun, start incrementing training counter and collect data
                % make min eyelid pos 0 on eyelid position scale. I also
                % have this set up to make the ~max eyelid pos 1 on the
                % eyelid position scale. Read function comments for
                % reasoning.
                % only need to do this on days that newTrialdata was not
                % generated...? not sure if I should do it at all anymore
                % actually...
                if size(trials.c_usdur,1) > 1
                    % OK204 has one day with only the calibration trial due
                    % to hardware problems. needed catch case for that
                    if trials.c_usdur(end-1,1)>0 && ~exist('newTrialdata.mat', 'file')==2 % to include the first day as possibly needing to be rezeroed, want to pick a middling trial with US presentation
                        trialsReZeroed = reZeroEyelidpos(trials,1);
                    else
                        trialsReZeroed = trials;
                    end
                else
                    trialsReZeroed = trials;
                end
                
                rbdat.eyelidpos=[rbdat.eyelidpos;trialsReZeroed.eyelidpos]; 
                rbdat.eyelidposOrigNorm = [rbdat.eyelidposOrigNorm; trials.eyelidpos];
                
                temp = 1:length(trials.c_csnum);
                rbdat.trialnum = [rbdat.trialnum;temp'];
                
                % there is something wrong with the baselinemvt
                % computation, it isn't sensitive enough & lets some things
                % through
                baselines = nan(length(trials.c_csdur),1);
                baselineMvt = zeros(length(trials.c_csdur),1);
                latencies = nan(length(trials.c_csdur),1);
                for t = 1:length(trials.c_usdur)
                    baselines(t,1)=mean(trialsReZeroed.eyelidpos(t,1:39));
                    deviations = trialsReZeroed.eyelidpos(t,1:39)-baselines(t,1);
                    if abs(max(deviations))>=0.1
                        baselineMvt(t,1) = 1;
                    end
                end
                
                rbdat.baseline = [rbdat.baseline; baselines];
                rbdat.baselineMvt = [rbdat.baselineMvt; baselineMvt];
                               
                rbdat.c_isi = [rbdat.c_isi;trials.c_isi];
                rbdat.c_csnum = [rbdat.c_csnum;trials.c_csnum];
                rbdat.c_csdur = [rbdat.c_csdur;trials.c_csdur];
                if strcmpi(hardware(m,1), 'arduino')
                    rbdat.c_usnum = [rbdat.c_usnum;trials.c_usnum];
                elseif strcmpi(hardware(m,1), 'tdt') % only allow this for the TDT mice, version of TDT code I was using only permits puff as US
                    rbdat.c_usnum = [rbdat.c_usnum;3*ones(length(trials.c_csnum),1)];
                end
                rbdat.c_usdur = [rbdat.c_usdur;trials.c_usdur];
                rbdat.type = [rbdat.type;strcmpi(trials.type,'Conditioning')]; % for ease of use later, let 1 = conditioning trials and 0=other
                rbdat.tDay = [rbdat.tDay;tDay*ones(length(trials.c_csnum),1)];
                
                thisDate = str2double(days(d).name);
                rbdat.date = [rbdat.date;thisDate*ones(length(trials.c_csnum),1)];
                [rbdat.mouse{end+1:end+length(trials.c_csnum), 1}]=...
                    deal(mice(m,1).name);
                
               
                if strcmpi(mice(m,1).name, 'OK001') ||...
                        strcmpi(mice(m,1).name, 'OK002') ||...
                        strcmpi(mice(m,1).name, 'OK003') ||...
                        strcmpi(mice(m,1).name, 'OK004')
                    % dim led is group 1, bright led is group 2
                    grouptemp = 1;
                elseif  strcmpi(mice(m,1).name, 'OK005') ||...
                        strcmpi(mice(m,1).name, 'OK006') ||...
                        strcmpi(mice(m,1).name, 'OK007') ||...
                        strcmpi(mice(m,1).name, 'OK008')
                    grouptemp = 2;
                end
                rbdat.group = [rbdat.group; grouptemp*ones(length(trials.c_csnum),1)];
                
                tDay = tDay + 1;
            end
        end
        
        
    end
    
    if isempty(timeVector)
        timeVector = trials.tm(1,:);
    end
end

cd(savedir)

tempstr = date;
correctFormatDate = reformatDate(tempstr);
filename = strcat(correctFormatDate,'_WTLEDCSUnpExt.mat');
save(filename, 'rbdat')

filename = strcat(correctFormatDate,'_WTLEDCSUnpExt_timeVector.mat');
save(filename, 'timeVector')