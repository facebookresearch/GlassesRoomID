% Copyright (c) Facebook, Inc. and its affiliates.

function [synthRir, shapedNoiseTimeDomain] = synthRirFromEstimate(rirEstimate, fs, earlyPartThreshMs, freqRangeRt60Hz)
% Thomas Deppisch, 2023

arguments
    rirEstimate (:,:)
    fs (1,1)
    earlyPartThreshMs (1,1) = 20
    freqRangeRt60Hz (1,2) = [100, 16000];
end

% estimate RT60
octaveFactorRT60 = 1;
[rt60, fAxisIta, rirEstEndSmp] = getT20Ita(rirEstimate,fs,octaveFactorRT60,freqRangeRt60Hz);

% interpolate linearly if some entries are still missing
if any(isnan(rt60),'all')
    rt60 = fillmissing(rt60,'linear');
end

% subband decomposition
filterOrder = 8;
freqRange = freqRangeRt60Hz;
fbBandwidth = '1 octave';
filtBank = octaveFilterBank(fbBandwidth,fs,'FilterOrder',filterOrder,'FrequencyRange',freqRange,'OctaveRatioBase',2);
fcFiltBank = getCenterFrequencies(filtBank)';

% fvt = fvtool(filtBank,"NFFT",2^16);
% set(fvt,FrequencyScale="log")
% zoom(fvt,[.01 24 -20 1])

assert(all(fcFiltBank == fAxisIta), 'Filter bank center frequencies must match the one from ITA!')

% remove direct sound
maxTimeDirSoundSearchMs = 50;
rirEstDirSoundIdx = findDirSoundPeakIdx(rirEstimate,fs,maxTimeDirSoundSearchMs);
earlyPartEndIdx = rirEstDirSoundIdx + round(earlyPartThreshMs/1000*fs);

rirEstWithoutDirSoundAndNoise = rirEstimate(earlyPartEndIdx+1:rirEstEndSmp,:);
numSamplesRevPart = size(rirEstWithoutDirSoundAndNoise,1);

rirSubbandsWithoutDS = filtBank(rirEstWithoutDirSoundAndNoise);
[numSamplesSubband,numSubbands,numChannels] = size(rirSubbandsWithoutDS);
groupDelaySubbands = round(getGroupDelays(filtBank)); % round for simplicity
rirSubbandWithoutDSPadded = [rirSubbandsWithoutDS;zeros(max(groupDelaySubbands),numSubbands,numChannels)];

% create noise and decompose into subbands
noiseSig = randn(numSamplesRevPart, numChannels);
noiseSigSubbands = filtBank(noiseSig);
noiseSigSubbandPadded = [noiseSigSubbands;zeros(max(groupDelaySubbands),numSubbands,numChannels)];

% reverberant energy estimation for each subband
noiseSubbandEnergyCorrected = zeros(size(rirSubbandsWithoutDS));
tAxRevPart = (0:numSamplesRevPart-1).'/fs;
for ii = 1:numSubbands
    % pad to account for different group delays
    currSubbandRirWithoutDSAligned = squeeze(rirSubbandWithoutDSPadded(groupDelaySubbands(ii)+1:numSamplesSubband+groupDelaySubbands(ii),ii,:));
    revEnergyLin = sum(currSubbandRirWithoutDSAligned.^2);

    % same with noise
    noiseSubbandAligned = squeeze(noiseSigSubbandPadded(groupDelaySubbands(ii)+1:numSamplesSubband+groupDelaySubbands(ii),ii,:));

    % apply decay
    noiseSubbandDecaying = noiseSubbandAligned .* 10.^((-60./rt60(ii,:).*tAxRevPart) ./ 20); 

    % coherence matching
    subbandCoherenceDesired = currSubbandRirWithoutDSAligned.' * currSubbandRirWithoutDSAligned;

    [V,D] = eig(subbandCoherenceDesired);% apply coherence mixing (Habets)
    C = sqrt(D) * V';
    noiseSubbandCohMod = noiseSubbandDecaying * conj(C);

    % adjust energy to energy of reverberant part of estimate
    noiseEnergyLin = sum(noiseSubbandCohMod.^2); 
    noiseSubbandEnergyCorrected(:,ii,:) = noiseSubbandCohMod .* sqrt(revEnergyLin ./ noiseEnergyLin);
end

% back to time domain
shapedNoiseTimeDomain = squeeze(sum(noiseSubbandEnergyCorrected,2));

% add direct part
rirEstEarlyPart = rirEstimate(1:earlyPartEndIdx, :);
synthRir = [rirEstEarlyPart; shapedNoiseTimeDomain];

% normalize
synthRir = synthRir./max(abs(synthRir(:)));
shapedNoiseTimeDomain = shapedNoiseTimeDomain./max(abs(shapedNoiseTimeDomain(:)));

