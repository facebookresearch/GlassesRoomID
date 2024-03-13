% Copyright (c) Facebook, Inc. and its affiliates.

function [psdMtx, fAx] = calculatePsdMatrix(sig, fs, stftBlockLenSmp, stftHopSizeSmp)
% Thomas Deppisch, 2023

stftWin = sqrt(hann(stftBlockLenSmp, 'periodic'));
fftLen = stftBlockLenSmp;
[sigStft,fAx,tAx] = stft(sig,stftWin,stftHopSizeSmp,fftLen,fs);

numFreqs = fftLen/2+1;
fAx = fAx(1:numFreqs);

numChannels = size(sig,2);
numBlocks = size(sigStft,2);
psdMtx = zeros(numChannels, numChannels, numFreqs);
for ff = 1:numFreqs
    X = squeeze(sigStft(ff,:,:));
    psdMtx(:,:,ff) = (X' * X) / numBlocks;
end
