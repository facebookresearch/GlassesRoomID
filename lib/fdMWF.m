function [h, irShort] = fdMWF(in, desired, fs, blockLenSmp, hopSizeSmp, filterLenSmp, regulWeight, win)
% This implements a frequency domain multichannel Wiener filter.
% Thomas Deppisch, 2023

arguments
    in (:,1)
    desired (:,:)
    fs (1,1)
    blockLenSmp (1,1) = 0.5*fs;
    hopSizeSmp (1,1) = 2048;
    filterLenSmp (1,1) = blockLenSmp/2;
    regulWeight (1,1) = 1e-4;
    win (:,1) = ones(blockLenSmp,1); %win = sqrt(hann(blockLenSmp, 'periodic'));
end

if size(in,1) ~= size(desired,1)
    % warning('Shortening signal length.')
    minLen = min(size(in,1), size(desired,1));
    in = in(1:minLen,:);
    desired = desired(1:minLen,:);
end

fftLen = blockLenSmp;
if mod(fftLen,2) == 1 % enforce even FFT length
    fftLen = fftLen + 1;
end

stftMtxIn = stft(in,win,hopSizeSmp,fftLen,fs);
stftMtxDesired = stft(desired,win,hopSizeSmp,fftLen,fs);

numFreqs = size(stftMtxDesired,1)/2+1;
numBlocks = size(stftMtxDesired,2);
numMics = size(stftMtxDesired,3);

h = zeros(numFreqs, numMics);

for ff = 1:numFreqs
    y = squeeze(stftMtxIn(ff,:)).';
    d = squeeze(stftMtxDesired(ff,:,:));

    if numMics == 1
        d = d.';
    end

    Ryy = 1/numBlocks * (conj(y).' * y); % the derivation assumes channels down the columns
    Ryd = 1/numBlocks * (conj(y).' * d);

    h(ff,:) = (Ryy + regulWeight) \ Ryd;
end

irShort = ifft([h; flipud(conj(h(2:end-1,:)))]);

shiftLenSmp = 100;
irShort = circshift(irShort, shiftLenSmp); % circshift helps to better preserve DRR!

fadeInLen = 60;
% fadeOutLen = round(blockLenSmp/10);
winIn = hann(2*fadeInLen);
winIn = winIn(1:fadeInLen);
% winOut = hann(2*fadeOutLen); % do we need the windowing at all?
% winOut = winOut(end-fadeOutLen+1:end);

irShort(1:fadeInLen,:) = irShort(1:fadeInLen,:) .* winIn;
% irRaw(end-fadeOutLen+1:end,:) = irRaw(end-fadeOutLen+1:end,:) .* winOut;

irShort = irShort(1:filterLenSmp,:);

