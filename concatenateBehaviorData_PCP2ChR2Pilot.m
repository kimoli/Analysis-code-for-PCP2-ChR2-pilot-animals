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
mice(1,1).name='OK202';
mice(2,1).name='OK203';
mice(3,1).name='OK204';
mice(4,1).name='OK206';
mice(5,1).name='OK207';
mice(6,1).name='OK208';
mice(7,1).name='OK209';
mice(8,1).name='OK210';


[hardware{1:8,1}] = deal('arduino');

rbdat.eyelidpos = [];
rbdat.trialnum = [];
rbdat.baseline = [];
rbdat.baselineMvt = [];
rbdat.encoder_displacement = [];
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
rbdat.laserDur = [];
rbdat.laserDel = [];
rbdat.eyelidposOrigNorm = [];
rbdat.manuallyProcessed = [];
rbdat.noCRTrialSelected = [];

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
                if trials.c_usdur(end-1,1)>0 && ~exist('newTrialdata.mat', 'file')==2 % to include the first day as possibly needing to be rezeroed, want to pick a middling trial with US presentation
                    trialsReZeroed = reZeroEyelidpos(trials,1);
                else
                    trialsReZeroed = trials;
                end
                
                rbdat.eyelidpos=[rbdat.eyelidpos;trialsReZeroed.eyelidpos(:,1:200)]; % force all the trials down to 200 frames, sometimes the TDT recording goes for ~260 frames but don't have room in this array for that
                rbdat.eyelidposOrigNorm = [rbdat.eyelidposOrigNorm; trials.eyelidpos(:, 1:200)];
                
                temp = 1:length(trials.c_csnum);
                rbdat.trialnum = [rbdat.trialnum;temp'];
                
                if noCRTrialsSelected
                    rbdat.noCRTrialSelected = [rbdat.noCRTrialSelected; ismember(temp',markedTrials)];
                else
                    rbdat.noCRTrialSelected = [rbdat.noCRTrialSelected; nan(length(trials.c_csnum),1)];
                end
                
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
               
                if isfield(trials,'encoder_displacement')
                    rbdat.encoder_displacement = [rbdat.encoder_displacement;trials.encoder_displacement(:,1:200)];
                else
                    [rows cols] = size(trials.eyelidpos);
                    cols = 200; % force this to be 200
                    rbdat.encoder_displacement = [rbdat.encoder_displacement;NaN(rows,cols,'like',rbdat.eyelidpos)];
                end
                
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
                rbdat.manuallyProcessed = [rbdat.manuallyProcessed; trialsManuallyProcessed*ones(length(trials.c_csnum),1)];
                
                thisDate = str2double(days(d).name);
                rbdat.date = [rbdat.date;thisDate*ones(length(trials.c_csnum),1)];
                [rbdat.mouse{end+1:end+length(trials.c_csnum), 1}]=...
                    deal(mice(m,1).name);
                
                rbdat.laserDur = [rbdat.laserDur;trials.laser.dur];
                rbdat.laserDel = [rbdat.laserDel;trials.laser.delay];
                
                if strcmpi(mice(m,1).name, 'OK202') ||...
                        strcmpi(mice(m,1).name, 'OK203') ||...
                        strcmpi(mice(m,1).name, 'OK204') ||...
                        strcmpi(mice(m,1).name, 'OK206')
                    % depends on not adding more animals to the groups
                    % let group 1 be experimental and group 2 be control
                    grouptemp = 1;
                elseif  strcmpi(mice(m,1).name, 'OK207') ||...
                        strcmpi(mice(m,1).name, 'OK208') ||...
                        strcmpi(mice(m,1).name, 'OK209') ||...
                        strcmpi(mice(m,1).name, 'OK210')
                    grouptemp = 2;
                end
                rbdat.group = [rbdat.group; grouptemp*ones(length(trials.c_csnum),1)];
                
                tDay = tDay + 1;
            end
        end
        
        
    end
    
    timeVector = trials.tm(1,:);
end

cd(savedir)

tempstr = date;
correctFormatDate = reformatDate(tempstr);
filename = strcat(correctFormatDate,'_PCP2ChR2PilotExpt_allAnimBehData.mat');
save(filename, 'rbdat')

filename = strcat(correctFormatDate,'_PCP2ChR2PilotExpt_timeVector.mat');
save(filename, 'timeVector')