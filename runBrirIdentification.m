% Copyright (c) Facebook, Inc. and its affiliates.

clear all
close all

addpath(genpath('./lib'))
addpath(genpath('./thirdparty'))

%% BRIR identification from speech captured with smart glasses
% cf. Deppisch, Meyer-Kahlen, Amengual Gari, 'Blind Identification of
% Binaural Room Impulse Responses from Head-Worn Microphone Arrays', 2023

% Scroll through this script to find the opportunity to listen to some renderings.

% load a speech signal
[sig,fs] = audioread('./data/speechMale.wav'); % speechFemale or speechMale
sig = [sig; zeros(fs/4,1)];

% load a RIR
rirFn = 'meetingRoom'; % choose meetingRoom, labRoomDry, or labRoomRev
speakerPos = 'right'; % choose left, center, or right

% far field RIR
rirStructFarField = load(['./data/RIRs/' rirFn '_' speakerPos 'Lsp.mat']);
% near field RIR from mouth simulator (simulating own speech of the wearer)
rirStructMouth = load(['./data/RIRs/' rirFn '_mouthSimulator.mat']);

% calculate ground truth parameters
octaveFactorT20 = 1;
numFrequenciesT20 = 7;
freqRangeT20Hz = [100, 8001];
[rtRirFar, fcT20, rirEndFar] = getT20Ita(rirStructFarField.roomIRs,fs,octaveFactorT20,freqRangeT20Hz);
[rtRirMouth, ~, rirEndMouth] = getT20Ita(rirStructMouth.roomIRs,fs,octaveFactorT20,freqRangeT20Hz);

tSplitMs = 2; % direct sound window
freqRangeDrrHz = freqRangeT20Hz;
drrDbRirFar = getDrr(rirStructFarField.roomIRs(1:rirEndFar,:),fs,tSplitMs);

%% create signals
snrDb = Inf;
disp(['Creating noisy speech signals with an SNR of ' num2str(snrDb) ' dB in room ' rirFn])

% convolve with speech
rirSigFar = fftfilt(rirStructFarField.roomIRs, sig);
rirSigFar = rirSigFar./max(abs(rirSigFar(:))) * 0.5;
rirSigMouth = fftfilt(rirStructMouth.roomIRs, sig);
rirSigMouth = rirSigMouth./max(abs(rirSigMouth(:))) * 0.5;

% add diffuse babble noise
[babbleNoise, noiseFs] = audioread('./data/diffBabble8Ch48kHz.wav');
babbleNoise = babbleNoise(1:length(sig), :);

% find times of active speech for the RMS calculation
speechRms = 10*log10(movmean(abs(sig).^2, 4*fs/1000));
rmsThresh = max(speechRms) - 25;
speechActiveIdx = speechRms > rmsThresh;

% add noise to have an average SNR of snrDb across channels
noiseGainFar = rms(rirSigFar(speechActiveIdx,:),'all')/(10^(snrDb/20)*rms(babbleNoise,'all'));
noiseGainMouth = rms(rirSigMouth(speechActiveIdx,:),'all')/(10^(snrDb/20)*rms(babbleNoise,'all'));

rirSigFarNoisy = rirSigFar + noiseGainFar .* babbleNoise;
rirSigMouthNoisy = rirSigMouth + noiseGainMouth .* babbleNoise;

%% uncomment to listen to the noisy speech signals that are used for the estimation
% soundsc(rirSigFarNoisy(:,5), fs)
% soundsc(rirSigMouthNoisy(:,5), fs)

%% dereverberate
disp('Starting dereverberation')

% gwpe params
gwpeParams.predictionDelayMs = 20;
gwpeParams.numIterations = 3;
gwpeParams.covSmoothingLen = 1;
gwpeParams.blockLen = 2048; 
gwpeParams.win = sqrt(hann(gwpeParams.blockLen, 'periodic'));
gwpeParams.hopsize = 128;
gwpeParams.fftLen = gwpeParams.blockLen; 
gwpeParams.predOrders = 36; % 12, 24
gwpeParams.predDelay = round(gwpeParams.predictionDelayMs/1000 / (gwpeParams.hopsize / fs)); 
gwpeParams.fs = fs;
gwpeParams.regulWeight = 1e-4;

[~, ~, rirSigFarDerev] = gwpeDereverberation(rirSigFarNoisy, gwpeParams);

%% beamform
disp('Applying beamformer')

% load ATFs for beamformer
atfStruct = load('./data/ATFs/glasses_on_HATS_ATFs_hor.mat');
atfIrGrid = atfStruct.atfIrs;
atfAziGridRad = atfStruct.atfGridAziEleDeg(:,1) * pi/180;
atfZenGridRad = pi/2 * ones(size(atfAziGridRad));
[atfGridCart(:,1), atfGridCart(:,2), atfGridCart(:,3)] = sph2cart(atfAziGridRad, pi/2-atfZenGridRad, ones(length(atfAziGridRad),1));
atfsFar = fft(atfIrGrid, gwpeParams.fftLen); % frequencies x channels x directions

% from mouth
atfStructMouth = load('./data/ATFs/glasses_on_HATS_NFATF.mat');
atfIrMouth = atfStructMouth.atfIrs;
atfMouth = fft(atfIrMouth, gwpeParams.fftLen);

% beamformer params
bfParams.fs = fs;
bfParams.bfType = 'MVDR';

if snrDb == inf
    bfParams.noisePsdMtx = 'identity';
else
    babbleNoiseShort = babbleNoise(1:fs,:); % take 1 s of babble noise to calculate the PSD
    [noisePsdMtx, fAx] = calculatePsdMatrix(babbleNoiseShort, fs, gwpeParams.blockLen, gwpeParams.hopsize);
    bfParams.noisePsdMtx = noisePsdMtx;
end

% find ATF closest to source direction
switch speakerPos
    case 'left'
        doaAziEleRad = [-30 0] * pi/180;
    case 'center'
        doaAziEleRad = [0 0] * pi/180;
    case 'right'
        doaAziEleRad = [30 0] * pi/180;
end

[doaCart(1),doaCart(2),doaCart(3)] = sph2cart(doaAziEleRad(1),doaAziEleRad(2),1);
[~,sourceAtfIdx] = min(sqrt(sum((doaCart - atfGridCart).^2, 2)));
sourceAtfFar = atfsFar(:,:,sourceAtfIdx);

% MVDR beamformer
rirSigFarDerevBfd = beamformTimeDomain(rirSigFarDerev, gwpeParams.blockLen, gwpeParams.hopsize, sourceAtfFar.', bfParams);
rirSigMouthBfd = beamformTimeDomain(rirSigMouthNoisy, gwpeParams.blockLen, gwpeParams.hopsize, atfMouth.', bfParams);

%% uncomment to listen to pseudo reference signals from far speech and own speech:
% soundsc(rirSigFarDerevBfd, fs)
% soundsc(rirSigMouthBfd, fs)

%% calculate RIR estimate using the frequency-domain multichannel Wiener filter
disp('Estimating RIRs')

% filter length is based on ground truth RT
gtAvgRt60Far = mean(rtRirFar, "all");
mwfFilterLenSmp = round(gtAvgRt60Far * fs);
mwfBlockLen = round(2 * mwfFilterLenSmp);
mwfWin = ones(mwfBlockLen,1);
mwfHopSize = 2048;
mwfRegulWeight = 1e-4;

[~, rirEstMwfFar] = fdMWF(rirSigFarDerevBfd, rirSigFarNoisy, ...
                           fs, mwfBlockLen, mwfHopSize, mwfFilterLenSmp, mwfRegulWeight, mwfWin);

% estimate RIRs from the mouth (own voice)
earMicsChIdx = [1, 8]; % own voice: only estimate RIRs to the microphones that are located closest to the ears
[~, rirEstMwfMouth] = fdMWF(rirSigMouthBfd, rirSigMouthNoisy(:,earMicsChIdx),...
                            fs, mwfBlockLen, mwfHopSize, mwfFilterLenSmp, mwfRegulWeight, mwfWin);

%% estimate parameters
disp('Estimating parameters')
[rtRirEstMwfFar, ~, rirEndMwfFar] = getT20Ita(rirEstMwfFar,fs,octaveFactorT20,freqRangeT20Hz);
[rtRirEstMwfMouth, ~, rirEndMwfMouth] = getT20Ita(rirEstMwfMouth,fs,octaveFactorT20,freqRangeT20Hz);

drrDbRirEstMwfFar = getDrr(rirEstMwfFar(1:rirEndMwfFar, :),fs,tSplitMs,freqRangeDrrHz);
drrDbRirEstMwfMouth = getDrr(rirEstMwfMouth(1:rirEndMwfMouth, :),fs,tSplitMs,freqRangeDrrHz);

%% run baseline algorithms
disp('Running baseline algorithms')
% RT
[rtAceRirFar, fcFiltBankAce] = estimateRt60BlindFb(rirSigFarNoisy, fs, octaveFactorT20, freqRangeT20Hz);

% DRR
voiceActive = simpleOracleVad(sig,rirStructFarField.roomIRs,fs); % oracle voicy activity detector

% limit frequency range as in the DRR estimator above
[bBp,aBp] = butter(4, freqRangeDrrHz/fs*2); % bandpass filter
rirSigFarNoisyBp = filtfilt(bBp,aBp,rirSigFarNoisy);

drrDbAceFar = estimateDrrBeamspace(rirSigFarNoisyBp, fs, voiceActive, ...
                                   doaAziEleRad, atfsFar, [atfAziGridRad, atfZenGridRad]);

%% calculate error metrics
disp('Calculating error metrics')
% mean absolute RT error in percent
getRelRtErrorPercent = @(rtGt_, rtEst_) mean(100 * abs(rtGt_-rtEst_)./rtGt_, 'all', 'omitnan');

rtErrMwfFar = getRelRtErrorPercent(rtRirFar, rtRirEstMwfFar);
rtErrAceFar = getRelRtErrorPercent(rtRirFar, rtAceRirFar);
rtErrMwfMouth = getRelRtErrorPercent(rtRirFar(:, earMicsChIdx), rtRirEstMwfMouth);

% mean absolute DRR error in dB
getAbsDrrErrorDb = @(drrDbGt_, drrDbEst_) mean(abs(drrDbGt_-drrDbEst_), 'omitnan');

drrErrMwfFar = getAbsDrrErrorDb(drrDbRirFar, drrDbRirEstMwfFar);
drrErrAceFar = getAbsDrrErrorDb(drrDbRirFar, drrDbAceFar);
drrErrMwfMouth = getAbsDrrErrorDb(drrDbRirFar(earMicsChIdx), drrDbRirEstMwfMouth);

% print results
resultsTable = table([rtErrMwfFar; rtErrMwfMouth; rtErrAceFar],[drrErrMwfFar; drrErrMwfMouth; drrErrAceFar],'VariableNames',{'RT Error (%)','DRR Error (dB)'},'RowName',{'MWF Far','MWF Mouth','ACE'}); 
disp(resultsTable)

%% synthesize RIRs from estimate
disp('Resynthesizing RIRs')
freqRangeSynth = [100,16000]; 
earlyPartThreshMs = 20; % time at which RIR is split into early and late part
rirMwfSynth = synthRirFromEstimate(rirEstMwfFar, fs, earlyPartThreshMs, freqRangeSynth);

%% render BRIRs
disp('Binaural Rendering')

% load an HRIR set, here we use https://zenodo.org/record/3928297/files/HRIR_L2702.mat
hrirStruct = load('HRIR_L2702.mat');
hL = double(hrirStruct.HRIR_L2702.irChOne);
hR = double(hrirStruct.HRIR_L2702.irChTwo);
hrirGridAziRad = double(hrirStruct.HRIR_L2702.azimuth.');
hrirGridZenRad = double(hrirStruct.HRIR_L2702.elevation.'); % the elevation angles actually contain zenith data between 0..pi
fsHrir = double(hrirStruct.HRIR_L2702.fs);

% load full-sphere ATFs
atfStructFullSphere = load('./data/ATFs/glasses_on_HATS_ATFs_sphere.mat');
atfIrGridFullSphere = atfStructFullSphere.atfIrs;
atfAziGridRadFS = atfStructFullSphere.atfGridAziEleDeg(:,1) * pi/180;
atfZenGridRadFS = (90-atfStructFullSphere.atfGridAziEleDeg(:,2)) * pi/180;

% calculate rendering filters
eMagLsFilterLen = 256;
eMagLsCutOnFreq = 2000;
[wMlsL, wMlsR] = getEMagLsFiltersFromAtf(hL, hR, [hrirGridAziRad, hrirGridZenRad], atfIrGridFullSphere, ...
                                        [atfAziGridRadFS atfZenGridRadFS], fs, eMagLsFilterLen, eMagLsCutOnFreq);

% calculate BRIR from RIR estimate
brirMwfEst = [sum(fftfilt(wMlsL, rirEstMwfFar), 2), sum(fftfilt(wMlsR, rirEstMwfFar), 2)];

% calculate BRIR from resynhesized RIR
brirMwfSynth = [sum(fftfilt(wMlsL, rirMwfSynth), 2), sum(fftfilt(wMlsR, rirMwfSynth), 2)];

% compare to binaural rendering using measured RIR
brirFar = [sum(fftfilt(wMlsL, rirStructFarField.roomIRs), 2), sum(fftfilt(wMlsR, rirStructFarField.roomIRs), 2)];

% convolve with signal
brirSigMwfEst = fftfilt(brirMwfEst, sig);
brirSigMwfSynth = fftfilt(brirMwfSynth, sig);
brirSigGt = fftfilt(brirFar, sig);

%% uncomment to listen to binaural renderings:
% soundsc(brirSigMwfEst, fs)    % BRIR estimate (may contain ringing)
% soundsc(brirSigMwfSynth, fs)  % resynthesized BRIR estimate
% soundsc(brirSigGt, fs)        % ground truth BRIR

%% plot
disp('Plotting RIRs')

xLims = [0, 10000];
yLims = [-60,0];

rirFarNormd = rirStructFarField.roomIRs ./ max(abs(rirStructFarField.roomIRs(:)));
rirEstFarNormd = rirEstMwfFar ./ max(abs(rirEstMwfFar(:)));
rirMouthNormd = rirStructMouth.roomIRs(:,earMicsChIdx) ./ max(abs(rirStructMouth.roomIRs(:,earMicsChIdx)),[],'all');
rirEstMouthNormd = rirEstMwfMouth ./ max(abs(rirEstMwfMouth(:)));

figure
subplot(211)
plot(db(abs(rirFarNormd(:,5))))
grid on
title('Far Field Speech: Measured RIR')
xlim(xLims)
ylim(yLims)
xlabel('t (samples)')
ylabel('Magnitude (dB)')

subplot(212)
plot(db(abs(rirEstFarNormd(:,5))))
grid on
title('Far Field Speech: Estimated RIR')
xlim(xLims)
ylim(yLims)
xlabel('t (samples)')
ylabel('Magnitude (dB)')

figure
subplot(211)
plot(db(abs(rirMouthNormd(:,1))))
grid on
title('Own Speech: Measured RIR')
xlim(xLims)
ylim(yLims)
xlabel('t (samples)')
ylabel('Magnitude (dB)')

subplot(212)
plot(db(abs(rirEstMouthNormd(:,1))))
grid on
title('Own Speech: Estimated RIR')
xlim(xLims)
ylim(yLims)
xlabel('t (samples)')
ylabel('Magnitude (dB)')

disp('Done!')
