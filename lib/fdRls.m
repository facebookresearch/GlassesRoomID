% Copyright (c) Facebook, Inc. and its affiliates.

function ir = fdRls(inMc, inBfd, fs, forgettingFact, blockLenSmp, hopSizeSmp, filterLenSmp, win)
% Frequency-domain RLS for blind system identification after Meyer-Kahlen,
% Schlecht, "﻿Blind Directional Room Impulse Response Parameterization from
% Relative Transfer Functions", 2023.
% Thomas Deppisch, 2023

arguments
    inMc (:,:)
    inBfd (:,1)
    fs (1,1)
    forgettingFact (1,1) = 0.99;
    blockLenSmp (1,1) = 0.5*fs;
    hopSizeSmp (1,1) = 2048;
    filterLenSmp (1,1) = blockLenSmp/2;
    win (:,1) = ones(blockLenSmp,1); %win = sqrt(hann(blockLenSmp, 'periodic'));
end

if size(inMc,1) ~= size(inBfd,1)
    warning('Shortening signal length.')
    minLen = min(size(inMc,1), size(inBfd,1));
    inMc = inMc(1:minLen,:);
    inBfd = inBfd(1:minLen,:);
end

fftLen = blockLenSmp;
if mod(fftLen,2) == 1 % enforce even FFT length
    fftLen = fftLen + 1;
end

numFreqs = fftLen/2+1;
numBlocks = floor((size(inMc, 1) - blockLenSmp) / hopSizeSmp );
numMics = size(inMc,2);

h = zeros(numFreqs, numMics);
phi = zeros(numFreqs, 1);
for bb = 1:numBlocks
    blockIdx = 1 + ((bb-1) * hopSizeSmp) + (0:blockLenSmp-1);
    inMcBlock = fft(inMc(blockIdx, :) .* win, fftLen);
    inBfdBlock = fft(inBfd(blockIdx, :) .* win, fftLen);
    inMcBlock = inMcBlock(1:numFreqs,:);
    inBfdBlock = inBfdBlock(1:numFreqs,:);

    epsilon = inMcBlock - h .* inBfdBlock;
    phi = forgettingFact * phi + conj(inBfdBlock) .* inBfdBlock;
    h = h + 1./phi .* conj(inBfdBlock) .* epsilon;
end

ir = ifft([h; flipud(conj(h(2:end-1,:)))]);

shiftLenSmp = 100;
ir = circshift(ir, shiftLenSmp);

fadeInLen = 60;
% fadeOutLen = blockLenSmp/10;
winIn = hann(2*fadeInLen);
winIn = winIn(1:fadeInLen);
% winOut = hann(2*fadeOutLen);
% winOut = winOut(end-fadeOutLen+1:end);

ir(1:fadeInLen,:) = ir(1:fadeInLen,:) .* winIn;
% irRaw(end-fadeOutLen+1:end,:) = irRaw(end-fadeOutLen+1:end,:) .* winOut;

ir = ir(1:filterLenSmp,:);

