function diffCoh = getDiffCohFromAtfs(atfIrs, fs, gridWeights, fftLen)
% atfIrs .. numSamples x numChannels x numDirections
% atfGridAziZenRad .. numDirections x 2
% Thomas Deppisch, 2023


% first create noise signals
numDirections = size(atfIrs,3);
numChannels = size(atfIrs,2);

noiseLen = 100 * fftLen;
atfNoise = zeros(noiseLen,numChannels);

for ii = 1:numDirections
    atfNoise = atfNoise + gridWeights(ii) * fftfilt(atfIrs(:,:,ii), randn(noiseLen,1));
end

blockLenSmp = fftLen;
win = hann(blockLenSmp);
hopSizeSmp = round(0.25 * blockLenSmp);
stftAtfNoise = stft(atfNoise,win,hopSizeSmp,fftLen,fs);
numFreqs = fftLen/2+1;
numBlocks = size(stftAtfNoise,2);
diffCoh = zeros(numChannels, numChannels, numFreqs);

for ff = 1:numFreqs
    currStft = squeeze(stftAtfNoise(ff,:,:));
    Pxy = currStft' * currStft ./ numBlocks;
    PxxPxy = diag(Pxy) * diag(Pxy)';

    diffCoh(:,:,ff) = Pxy ./ sqrt(PxxPxy);
end

diffCoh = real(diffCoh);

