function voiceActive = simpleOracleVad(sig,rir,fs)
% Simple oracle voice activity detection
% Calculates times during which voice is active in rirSig by analyzing the
% noise-free sig
% Thomas Deppisch, 2023

% align signal according to RIR direct sound peak
maxTimeMs = 20;
t0Smp = findDirSoundPeakIdx(mean(rir,2),fs,maxTimeMs);
sig = circshift(sig, t0Smp);

vadDynDb = 40;
voiceActive = db(abs(sig)) > (max(db(abs(sig))) - vadDynDb);

% plot VAD
% figure
% plot(db(abs(sig)))
% hold on
% plot(db(mean(abs(rirSig), 2)))
% plot(voiceActive*20)
% legend('dry sig','rir sig','vad')
% grid on
