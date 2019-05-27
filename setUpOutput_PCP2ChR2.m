function [output] = setUpOutput_PCP2ChR2()
output.mouse = {};
output.date = [];
output.meanCRAdjAmp = [];
output.meanPrepuffAmp = [];
output.hitCRAdjAmp = [];
output.missCRAdjAmp = [];
output.CRProb = [];
output.meanAStartleAmp = [];

output.meanMvtLatency = [];

output.meanURAmp = [];
output.meanURIntegral = [];
output.meanHitURAmp = [];
output.meanHitURIntegral = [];
output.meanMissURAmp = [];
output.meanMissURIntegral = [];
output.meanURAmpAdj = [];
output.meanURIntegralAdj = [];
output.meanHitURAmpAdj = [];
output.meanHitURIntegralAdj = [];
output.meanMissURAmpAdj = [];
output.meanMissURIntegralAdj = [];

output.meanEyelidTrace = [];
output.semEyelidTrace = [];
output.meanHitEyelidTrace = [];
output.semHitEyelidTrace = [];
output.meanMissEyelidTrace = [];
output.semMissEyelidTrace = [];
output.meanEyelidTraceAdj = [];
output.semEyelidTraceAdj = [];
output.meanHitEyelidTraceAdj = [];
output.semHitEyelidTraceAdj = [];
output.meanMissEyelidTraceAdj = [];
output.semMissEyelidTraceAdj = [];

output.meanURAmpScoredMisses = [];
output.meanAdjURAmpScoredMisses = [];
output.medianURAmpScoredMisses = [];
output.medianAdjURAmpScoredMisses = [];

output.isext = [];

output.meancrintegral = [];
output.meanhitcrintegral = [];

output.CRAdjAmpEarlyInSess = [];
output.CRAdjAmpLateInSess = [];

output.meanCRLatency = [];
end