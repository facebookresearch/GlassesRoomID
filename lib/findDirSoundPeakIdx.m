function t0Smp = findDirSoundPeakIdx(ir,fs,maxTimeMs)
% The direct sound peak here is found as the first of the largest N peaks within the first 20 ms.
% Thomas Deppisch, 2023

if nargin < 3 || isempty(maxTimeMs)
    maxTimeMs = 20;
end
maxTimeSmp = round(maxTimeMs/1000 * fs);

[peakVals, peakIdx] = findpeaks(abs(ir(1:maxTimeSmp)), 'MinPeakDistance', 10,'SortStr', 'descend', 'NPeaks', 5);
[~,firstPeakSubIdx] = min(peakIdx);
t0Smp = peakIdx(firstPeakSubIdx);

%disp(['findDirSoundPeakIdx: found direct sound peak at sample ' num2str(t0Smp) ' (' num2str(round(t0Smp/fs*1000)) ' ms)'])