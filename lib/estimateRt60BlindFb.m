% Copyright (c) Facebook, Inc. and its affiliates.

function [rt60, fcFiltBank] = estimateRt60BlindFb(rirSig, fs, bandsPerOctave, freqRangeHz, fdrBlockLenMs, fdrOverlapRatio)
% Implementation of "﻿A blind algorithm for reverberation-time estimation
% using subband decomposition of speech signals" by Prego et al.
% Thomas Deppisch, 2023

arguments
    rirSig (:,:) % time x channels
    fs (1,1)
    bandsPerOctave (1,1)
    freqRangeHz (1,2)
    fdrBlockLenMs (1,1) = 50
    fdrOverlapRatio (1,1) = 0.25
end

filterOrder = 8;
switch bandsPerOctave
    case 1
        fbBandwidth = '1 octave';
    case 3
        fbBandwidth = '1/3 octave';
    otherwise
        error('chosen number of bandsPerOctave not available')
end

filtBank = octaveFilterBank(fbBandwidth, fs, 'FilterOrder', filterOrder, 'FrequencyRange', freqRangeHz, 'OctaveRatioBase', 2);
fcFiltBank = getCenterFrequencies(filtBank);

rirSigSubbands = filtBank(rirSig);
[numSamplesSubband, numSubbands, numChannels] = size(rirSigSubbands);
groupDelaySubbands = round(getGroupDelays(filtBank));
rirSigSubbandsPadded = [rirSigSubbands;zeros(max(groupDelaySubbands),numSubbands,numChannels)];

% calculate frames to find free decay regions
% remove group delay and buffer
fdrBlockLenSmp = round(fdrBlockLenMs / 1000 * fs);
fdrOverlapSmp = round(fdrOverlapRatio * fdrBlockLenSmp);
fdrHopSizeSmp = fdrBlockLenSmp - fdrOverlapSmp;

fdrDetectionTimeSec = 0.5;

% minimum number of consecutive subband frames with decreasing energy 
% to detect a free-decay region 
Llim = ceil(fdrDetectionTimeSec * fs / fdrHopSizeSmp);
LlimEffMin = 3; % if no FDR is found, the limit is iteratively decreased to this minimum amount
upperLimDb = -5;

rt60 = zeros(numSubbands,numChannels);

for cc = 1:numChannels
    regionLimits = cell(numSubbands,1);

    for ff = 1:numSubbands
        rirSigSubbandAligned = squeeze(rirSigSubbandsPadded(groupDelaySubbands(ff)+1:numSamplesSubband+groupDelaySubbands(ff),ff,cc));
        rirSigSubbandBuffered = buffer(rirSigSubbandAligned, fdrBlockLenSmp, fdrOverlapSmp);
        numBlocks = size(rirSigSubbandBuffered, 2);
    
        % start and end time of blocks in samples
        tBlocksSmpStart = (1:fdrHopSizeSmp:fdrHopSizeSmp*numBlocks)';
        tBlocksSmpEnd = tBlocksSmpStart + fdrBlockLenSmp - 1;
    
        frameEnergy = sum(abs(rirSigSubbandBuffered).^2);
    
        regionLimits{ff} = cell(1,1);
        numRegionsPerBandFound = 0;
        currLlim = Llim;
    
        while numRegionsPerBandFound < 1 && currLlim >= LlimEffMin
            for bb = 1:numBlocks - currLlim
                currFrameEnergy = frameEnergy(bb:bb+currLlim);
                if all(currFrameEnergy(1:end-1) > currFrameEnergy(2:end)) % check if energy is decaying in all blocks
                    regionLimits{ff}{numRegionsPerBandFound+1} = tBlocksSmpStart(bb):min(tBlocksSmpEnd(bb+currLlim), numSamplesSubband);
                    numRegionsPerBandFound = numRegionsPerBandFound+1;
                end
            end
    
            if numRegionsPerBandFound == 0
                currLlim = currLlim - 1;
            end
        end
    
        if numRegionsPerBandFound == 0
            warning(['no FDR found for bin ' num2str(ff)])
        else
            % calculate subband EDF
            rt60Candidates = zeros(numRegionsPerBandFound,1);
            r2 = zeros(numRegionsPerBandFound,1);
            for rr = 1:numRegionsPerBandFound
                rirSubbandEnergy = abs(rirSigSubbandAligned).^2;
                currRegionLimits = regionLimits{ff}{rr}(rirSubbandEnergy(regionLimits{ff}{rr}) > 0);
                normalizer = sum(rirSubbandEnergy(currRegionLimits));
                subEdf = 10*log10(flip(cumsum(flip(rirSubbandEnergy(currRegionLimits)))) ./ normalizer);
    
                % calculate the MMSE line fit, discarding values above -5 dB
                upperLim = find(subEdf < upperLimDb, 1, 'first');
                lsY = subEdf(upperLim:end);
                lsX = (1:length(lsY))';

                %lowerLimStartIdx = find(lsY < upperLimDb-5, 1, 'first');
                %if isempty(lowerLimStartIdx)
                    lowerLimStartIdx = min(length(lsY), 0.1 * fs);
                %end

                % choose end point that yields minimum MSE fit
                for lsXEnd = lowerLimStartIdx:0.01*fs:length(lsY)                
                    [rtSlopeCandidate,~,~,r2Candidate] = linRegression(lsX(1:lsXEnd), lsY(1:lsXEnd));
                    if r2Candidate > r2(rr)
                        r2(rr) = r2Candidate;
                        rtSlope = rtSlopeCandidate;
                    end
                end
                rt60Candidates(rr) = -60/rtSlope/fs;
            end
    
            if numRegionsPerBandFound == 1
                rt60(ff,cc) = rt60Candidates;
            else
                rt60(ff,cc) = median(rt60Candidates);

                % instead of median, take candidate with the best linear
                % fit
                %[~,maxR2Idx] = max(r2);
                %rt60(ff,cc) = rt60Candidates(maxR2Idx);
            end
        end
    
    end
end
