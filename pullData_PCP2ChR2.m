function [output, blockedCRadjamp] = pullData_PCP2ChR2(eyelidpos, noCRTrialSelected, usdur, pairedTrials, timeVector, crcrit, ...
    output, m, day)

baseline = nan(length(pairedTrials),1);
stable = nan(length(pairedTrials),1);
cradjamp = nan(length(pairedTrials),1);
prepuffamp = nan(length(pairedTrials),1);
crlatency = nan(length(pairedTrials),1); % going to define cr latency as the time that FEC passes CR threshold
uramp = nan(length(pairedTrials),1);
urampadj = nan(length(pairedTrials),1);
astartleamp = nan(length(pairedTrials),1);
urint = nan(length(pairedTrials),1);
crint = nan(length(pairedTrials),1);
urintadj = nan(length(pairedTrials),1);
eyelidposadj = nan(length(pairedTrials),340);
for i = 1:length(pairedTrials)
    % added the if statements in this loop to deal with a discrepancy in my
    % experiment dataset and the WT animal dataset, should fix at
    % the source and then come back to clean up this line
    % (although the code won't break if I forget about this)
    
    baseline(i,1) = mean(eyelidpos(pairedTrials(i), 1:39));
    cradjamp(i,1) = eyelidpos(pairedTrials(i), 76) - baseline(i,1);
    prepuffamp(i,1) = eyelidpos(pairedTrials(i), 82) - baseline(i,1); % accounts for delay of the tubing, delay is actually a little bit longer than this
    uramp(i,1) = max(eyelidpos(pairedTrials(i), 80:100)); % max FEC in the 100 ms after US triggered
    urampadj(i,1) = uramp(i,1)-baseline(i,1);
    urint(i,1) = trapz(timeVector(1,80:200), eyelidpos(pairedTrials(i), 80:200)); % area under the curve for the remainder of the trial after the US is triggered
    crint(i,1) = trapz(timeVector(1,45:80), eyelidpos(pairedTrials(i), 45:80)-baseline(i,1));
    urintadj(i,1) = trapz(timeVector(1,80:200), eyelidpos(pairedTrials(i), 80:200)-baseline(i,1));
    
    found = 0;
    latency = nan;
    lookhere = 51;
    while found == 0 && lookhere<=340
        if eyelidpos(pairedTrials(i), lookhere)-baseline(i,1) > crcrit
            latency = lookhere;
            found = 1;
        else
            lookhere = lookhere+1;
        end
    end
    crlatency(i,1) = latency;

    % define a trial with unstable baseline as one that has movement of >0.1
    % FEC during the baseline OR one that has nonzero velocity
    % at the time the CS turns on
    baselinedevs = diff(eyelidpos(pairedTrials(i),1:39));
    velocity = baselinedevs/0.005; % 5 ms bins
    %meanvel = mean(velocity);
    %stdvel = std(velocity);
    %veldiffs = abs(velocity - meanvel);
    
    minval = min(eyelidpos(pairedTrials(i),1:39));
    maxval= max(eyelidpos(pairedTrials(i),1:39));
    
    if maxval - minval > 0.1 || max(abs(velocity))>2 % velocity cutoff is arbitrary but empirically chosen
        stable(i,1) = 0;
    else
        stable(i,1) = 1;
    end
    
    if stable(i,1)
        eyelidposadj(i,1:340)=eyelidpos(pairedTrials(i),1:340)-baseline(i,1);
    else
        eyelidposadj(i,1:340)=nan(1,340);
    end
    
    
    % startle amplitude
    astartleamp(i,1) = max(eyelidpos(pairedTrials(i), 40:50)) - baseline(i,1); % the max amplitude in the first 50 ms after the CS is presented
end

% output for the blocked data
blockstart = 1;
blockend = 20;
blocksize = 20;
blockedCRadjamp = nan(floor(length(cradjamp)./20),1);
placeidx = 1;
while blockend<=length(cradjamp)
    if blockend+blocksize > length(cradjamp) % deal with the case where there is a number of trials not divisible by 5
        blockend = length(cradjamp);
    end
    
    tempcradjamp = cradjamp(blockstart:blockend,1);
    tempbaseline = baseline(blockstart:blockend,1);
    averageme = tempcradjamp(tempbaseline<0.3,1);
    blockedCRadjamp(placeidx,1) = nanmean(averageme);
    %blockedCRadjamp(placeidx,1) = sum(averageme>crcrit)/length(averageme); % do CR probability as a test
    
    blockstart = blockstart+blocksize;
    blockend = blockend+blocksize;
    placeidx = placeidx + 1;
    
    clear tempcradjamp tempbaseline averageme
end

% organize output for daily data
hitTrials = sum(cradjamp>crcrit & stable & baseline<0.3);
totalTrials = sum(stable & baseline<0.3);
output.CRProb(end+1,1) = hitTrials/totalTrials;

output.meanCRLatency(end+1,1) = nanmean(crlatency(cradjamp>crcrit & stable & baseline<0.3));

output.mouse = [output.mouse; m(:,1)];
output.date(end+1,1) = day;

output.meanCRAdjAmp(end+1,1) = mean(cradjamp(stable & baseline<0.3));
output.meanPrepuffAmp(end+1,1) = mean(prepuffamp(stable & baseline<0.3));
output.hitCRAdjAmp(end+1,1) = mean(cradjamp(stable & baseline<0.3 & cradjamp>crcrit));
output.missCRAdjAmp(end+1,1) = mean(cradjamp(stable & baseline<0.3 & cradjamp<=crcrit));

nt = 20;
if length(cradjamp)> nt
    tempamp = cradjamp(1:nt,:);
    tempstable = stable(1:nt,:);
    tempbaseline = baseline(1:nt,:);
    output.CRAdjAmpEarlyInSess(end+1,1) = mean(tempamp(tempstable & tempbaseline<0.3));
    
    tempamp = cradjamp(end-nt:end,:);
    tempstable = stable(end-nt:end,:);
    tempbaseline = baseline(end-nt:end,:);
    output.CRAdjAmpLateInSess(end+1,1) = mean(tempamp(tempstable & tempbaseline<0.3));
else
    output.CRAdjAmpEarlyInSess(end+1,1) = nan;
    output.CRAdjAmpLateInSess(end+1,1) = nan;
end

output.meanAStartleAmp(end+1,1) = mean(astartleamp(stable & baseline<0.3));


output.meanURAmp(end+1,1) = mean(uramp(stable & baseline<0.3));
output.meanHitURAmp(end+1,1) = mean(uramp(stable & baseline<0.3 & cradjamp>=0.1));
output.meanMissURAmp(end+1,1) = mean(uramp(stable & baseline<0.3 & cradjamp<0.1));
output.meanURAmpAdj(end+1,1) = mean(urampadj(stable & baseline<0.3));
output.meanHitURAmpAdj(end+1,1) = mean(urampadj(stable & baseline<0.3 & cradjamp>=0.1));
output.meanMissURAmpAdj(end+1,1) = mean(urampadj(stable & baseline<0.3 & cradjamp<0.1));

output.meancrintegral(end+1, 1) = mean(crint(stable & baseline<0.3));
output.meanhitcrintegral(end+1, 1) = mean(crint(stable & baseline<0.3 & cradjamp>=crcrit));
output.meanURIntegral(end+1,1)=mean(urint(stable & baseline<0.3));
output.meanHitURIntegral(end+1,1)=mean(urint(stable & baseline<0.3 & cradjamp>=crcrit));
output.meanMissURIntegral(end+1,1)=mean(urint(stable & baseline<0.3 & cradjamp<crcrit));
output.meanURIntegralAdj(end+1,1)=mean(urintadj(stable & baseline<0.3));
output.meanHitURIntegralAdj(end+1,1)=mean(urintadj(stable & baseline<0.3 & cradjamp>=crcrit));
output.meanMissURIntegralAdj(end+1,1)=mean(urintadj(stable & baseline<0.3 & cradjamp<crcrit));

% what kind of session is this? (adding this in for the extinction
% dataset analysis)
% I also just noticed that the variable name 'pairedtrials' is
% misleading because after day 1 I do not require that the US
% and CS were both presented, I just require that neuroblinks
% saved them as trials of type 'Conditioning'
if size(pairedTrials,1)>6 % catch for the day with hardware failure with only one trial (OK204 190517)
    if usdur(pairedTrials(end-5),1)==0
        % if the second to last trial had a US of 0 duration, then the session
        % was definitely an extinction session. On day 1s there're some
        % number of 0-USdur trials at the beginning of the session so I
        % didn't want to include that as a possibility
        output.isext(end+1,1)=1;
    else
        output.isext(end+1,1)=0;
    end
else
    output.isext(end+1,1)=0;
end

% eyelid trace stuff
output.meanEyelidTrace(end+1, 1:340) = nanmean(eyelidpos(pairedTrials(find(stable)),:));
output.semEyelidTrace(end+1, 1:340) = nanstd(eyelidpos(pairedTrials(find(stable)),:))/sqrt(sum(stable));
output.meanHitEyelidTrace(end+1, 1:340) = nan(1,340);
output.semHitEyelidTrace(end+1, 1:340) = nan(1,340);
output.meanMissEyelidTrace(end+1, 1:340) = nan(1,340);
output.semMissEyelidTrace(end+1, 1:340) = nan(1,340);

output.meanEyelidTraceAdj(end+1, 1:340) = nanmean(eyelidposadj);
output.semEyelidTraceAdj(end+1, 1:340) = nanstd(eyelidposadj)/sqrt(sum(~isnan(eyelidposadj)));
output.meanHitEyelidTraceAdj(end+1, 1:340) = nan(1,340);
output.semHitEyelidTraceAdj(end+1, 1:340) = nan(1,340);
output.meanMissEyelidTraceAdj(end+1, 1:340) = nan(1,340);
output.semMissEyelidTraceAdj(end+1, 1:340) = nan(1,340);
if hitTrials > 1
    output.meanHitEyelidTrace(end, 1:340) = nanmean(eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :));
    output.semHitEyelidTrace(end, 1:340) = nanstd(eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :))/sqrt(sum(stable));
    output.meanHitEyelidTraceAdj(end, 1:340) = nanmean(eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :));
    output.semHitEyelidTraceAdj(end, 1:340) = nanstd(eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :))/sqrt(sum(stable));
elseif hitTrials == 1
    output.meanHitEyelidTrace(end, 1:340) = (eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :));
    output.semHitEyelidTrace(end, 1:340) = nan(1,340);
    output.meanHitEyelidTraceAdj(end, 1:340) = (eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :));
    output.semHitEyelidTraceAdj(end, 1:340) = nan(1,340);
end
if hitTrials < totalTrials
    output.meanMissEyelidTrace(end, 1:340) = nanmean(eyelidposadj(cradjamp<crcrit & stable & baseline<0.3, :));
    output.semMissEyelidTrace(end, 1:340) = nanstd(eyelidposadj(cradjamp<crcrit & stable & baseline<0.3,:))/sqrt(length(eyelidposadj));
    output.meanMissEyelidTraceAdj(end, 1:340) = nanmean(eyelidposadj(cradjamp<crcrit & stable & baseline<0.3,:));
    output.semMissEyelidTraceAdj(end, 1:340) = nanstd(eyelidposadj(cradjamp<crcrit & stable & baseline<0.3,:))/sqrt(length(eyelidposadj));
end

% miss trials only stuff
CRsScoredThisDay = isnan(noCRTrialSelected)==0;
if sum(CRsScoredThisDay)>0
    output.meanURAmpScoredMisses(end+1, 1) = nanmean(uramp(noCRTrialSelected==1));
    output.meanAdjURAmpScoredMisses(end+1, 1) = nanmean(urampadj(noCRTrialSelected==1));
    output.medianURAmpScoredMisses(end+1, 1) = nanmedian(uramp(noCRTrialSelected==1));
    output.medianAdjURAmpScoredMisses(end+1, 1) = nanmedian(urampadj(noCRTrialSelected==1));
else
    output.meanURAmpScoredMisses(end+1, 1) = NaN;
    output.meanAdjURAmpScoredMisses(end+1, 1) = NaN;
    output.medianURAmpScoredMisses(end+1, 1) = NaN;
    output.medianAdjURAmpScoredMisses(end+1, 1) = NaN;
end
end