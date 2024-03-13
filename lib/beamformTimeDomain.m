% Copyright (c) Facebook, Inc. and its affiliates.

function sigBfd = beamformTimeDomain(sig, stftBlockLenSmp, stftHopSizeSmp, atfSource, params)
% Thomas Deppisch, 2023

% atfSource .. numChannels x numFreqs

stftWin = sqrt(hann(stftBlockLenSmp, 'periodic'));
fftLen = stftBlockLenSmp;
sigStft = stft(sig,stftWin,stftHopSizeSmp,fftLen,params.fs);
numFrequencies = fftLen/2+1;
regulConst = 1e-4;

if strcmp(params.bfType,'MVDR') && isfield(params,'noisePsdMtx')
    [stftBfd, bfWeights] = applyBeamformerStft(sigStft(1:numFrequencies,:,:), atfSource, params.bfType, regulConst, params.noisePsdMtx);
else
    [stftBfd, bfWeights] = applyBeamformerStft(sigStft(1:numFrequencies,:,:), atfSource, params.bfType, regulConst);
end

sigBfd = istft([stftBfd; conj(flipud(stftBfd(2:end-1,:,:)))],stftWin,stftHopSizeSmp);

