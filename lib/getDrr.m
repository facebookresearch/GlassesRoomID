function drrDb = getDrr(ir,fs,tSplitMs,freqRangeHz)
% simple DRR calculation
% Find direct sound peak, calculate DRR as energy ratio in a 5 ms window
% around the peak and the rest.
% The direct sound peak here is found as the first of the largest 3 peaks within the first 20 ms.
% Use tSplitMs to split direct and reverberant part at some later time
% instant.

% Thomas Deppisch, 2023

numChannels = size(ir,2);

if nargin < 4 || isempty(freqRangeHz)
    freqRangeHz = [50 16000];
end

dirSoundWinLenMs = 2;
dirSoundWinLenSmp = dirSoundWinLenMs/1000 * fs;
halfDirSoundWinLenSmp = round(dirSoundWinLenSmp/2);

if nargin < 3 || isempty(tSplitMs)
    tSplitMs = halfDirSoundWinLenSmp;
end

[bBp,aBp] = butter(4, freqRangeHz/fs*2); % bandpass filter
irFilt = filtfilt(bBp,aBp,ir);

tSplitSmp = round(tSplitMs/1000 * fs);
drrDb = zeros(numChannels,1);

for chIdx = 1:numChannels
    t0Smp = findDirSoundPeakIdx(irFilt(:,chIdx),fs);
    
    dirPart = irFilt(max(1, t0Smp-halfDirSoundWinLenSmp):t0Smp+tSplitSmp,chIdx);
    revPart = irFilt(t0Smp+tSplitSmp+1:end,chIdx);
    
    %drrDb(chIdx) = 10*log10(trapz(dirPart.^2) ./ trapz(revPart.^2));
    drrDb(chIdx) = 10*log10(sum(dirPart.^2) ./ sum(revPart.^2));

    % figure
    % plot(db(abs(irFilt(:,chIdx))))
    % hold on
    % xline(t0Smp)

end