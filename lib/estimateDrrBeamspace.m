function drrEst = estimateDrrBeamspace(sig, fs, activeVoiceTimes, ...
                                       sourceDirAziEleRad, atfs, atfGridAziZenRad)
% DRR estimation as proposed in Hioka, Niwa, "PSD estimation in Beamspace
% for Estimating Direct-to-Reverberant Ratio from A Reverberant Speech
% Signal".
% This implementation uses 2 beamformers (as in the publication) and thus
% assumes only a single active source. It also assumes the source being
% located in the horizontal plane.
% 
% Thomas Deppisch, 2023

stftBlockLenSmp = 2048;
stftHopSizeSmp = round(stftBlockLenSmp/2);
stftOverlapSmp = stftBlockLenSmp - stftHopSizeSmp;
stftWin = sqrt(hann(stftBlockLenSmp, 'periodic'));
fftLen = stftBlockLenSmp;
[sigStft, fAx, tAx] = stft(sig,stftWin,stftHopSizeSmp,fftLen,fs);

atfs = permute(atfs, [2,3,1]);
[numChannels, numPwDirs, numFrequenciesDoubleSided] = size(atfs);
numFrequencies = numFrequenciesDoubleSided/2+1;

assert(size(atfs,3) == size(sigStft,1), 'ATFs and signal STFT need same DFT length!')

[atfGridXYZ(:,1), atfGridXYZ(:,2), atfGridXYZ(:,3)] = sph2cart(atfGridAziZenRad(:,1), pi/2-atfGridAziZenRad(:,2), ones(numPwDirs,1));

% steer one beamformer in source direction
[sourceDoaCart(1),sourceDoaCart(2),sourceDoaCart(3)] = sph2cart(sourceDirAziEleRad(1), sourceDirAziEleRad(2), 1);
[~,atfIdxClosestToMedianDoa] = min(sqrt(sum((sourceDoaCart - atfGridXYZ).^2, 2)));
atfsSourceDir = squeeze(atfs(:,atfIdxClosestToMedianDoa,1:numFrequencies));

bfType = 'delayAndSum';
[stftBfd1, bfWeights1] = applyBeamformerStft(sigStft(1:numFrequencies,:,:), atfsSourceDir, bfType);

% second beamformer in direction pi/3 azimuth
bf2DirAziEleRad = [sourceDirAziEleRad(1)+pi/3 sourceDirAziEleRad(2)]; 
% choosing the same zenith angle as the source beamformer, this might not be a good choice if the source is outside the horizontal plane
[bf2DoaCart(1),bf2DoaCart(2),bf2DoaCart(3)] = sph2cart(bf2DirAziEleRad(1), bf2DirAziEleRad(2), 1);
[~,atfIdxBf2] = min(sqrt(sum((bf2DoaCart - atfGridXYZ).^2, 2)));
atfsBf2 = squeeze(atfs(:,atfIdxBf2,1:numFrequencies));
[stftBfd2, bfWeights2] = applyBeamformerStft(sigStft(1:numFrequencies,:,:), atfsBf2, bfType);

% exclude STFT blocks without voice activity
activeVoiceTimes = [zeros(stftBlockLenSmp-1,1); activeVoiceTimes]; % pre-pad with zeros as done in STFT implementation for time alignment
activeVoiceTimesBuffered = buffer(activeVoiceTimes, stftBlockLenSmp, stftOverlapSmp, 'nodelay');

% exclude stft blocks without active voice
vadThreshold = 0.6; % if 60% of samples within a block have active voice, we consider the block in the further processing
blockContainsVoice = (sum(activeVoiceTimesBuffered,1) / stftBlockLenSmp) >= vadThreshold;

% figure
% plot(blockContainsVoice)

stftBfd1 = stftBfd1(:,blockContainsVoice);
stftBfd2 = stftBfd2(:,blockContainsVoice);
numBlocksWithVoice = sum(blockContainsVoice);

% estimate PSD for beamformer outputs
psdBf1 = sum(conj(stftBfd1) .* stftBfd1, 2) ./ numBlocksWithVoice;
psdBf2 = sum(conj(stftBfd2) .* stftBfd2, 2) ./ numBlocksWithVoice;

% calculate beamformer gains in steering direction and integral over all
% directions
G1 = abs(sum(conj(bfWeights1) .* atfsSourceDir)).^2;
G2 = abs(sum(conj(bfWeights2) .* atfsSourceDir)).^2;

G1Int = 0;
G2Int = 0;
for ii = 1:numPwDirs
    currAtfs = squeeze(atfs(:, ii, 1:numFrequencies));
    G1Int = G1Int + abs(sum(conj(bfWeights1) .* currAtfs)).^2;
    G2Int = G2Int + abs(sum(conj(bfWeights2) .* currAtfs)).^2;
end

% do the integration assuming an equal spacing in grid directions
G1Int = G1Int ./ numPwDirs;
G2Int = G2Int ./ numPwDirs;

% estimate the direct and reverberant PSDs
psdDirRev = zeros(numFrequencies,2);
for ff = 1:numFrequencies
    G = [G1(ff) G1Int(ff); G2(ff) G2Int(ff)];
    psdDirRev(ff,:) = pinv(G) * [psdBf1(ff); psdBf2(ff)];
end

if any(psdDirRev < 0, 'all')
    % warning('estimateDrrBeamspace: setting negative PSD estimates to their absolute value') 
    psdDirRev = abs(psdDirRev); % this is proposed in eq. 14 in Hioka et al.,
    % "Underdetermined sound source separation using power spectrum density estimated by combination of directivity gain"
end

drrEst = 10*log10(sum(psdDirRev(:,1)) ./ (4*pi*sum(psdDirRev(:,2))));

