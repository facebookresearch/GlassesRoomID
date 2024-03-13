% Copyright (c) Facebook, Inc. and its affiliates.

function [origStft, dereverbStft, dereverbSig, reverbSig, filterCoeffs] = gwpeDereverberation(sig, params)
% Generalized Weighted Prediction Error (GWPE)
% This function only allows the identity matrix approach for covariance
% estimation, but it is about 4 times faster than the "full" implementation.

% Thomas Deppisch, 2023

blockLen = params.blockLen;
hopsize = params.hopsize;
fftLen = params.fftLen;
predOrders = params.predOrders;
predDelay = params.predDelay;
numIterations = params.numIterations;
covSmoothingLen = params.covSmoothingLen;
regulWeight = params.regulWeight;

if size(predOrders,1) == 1
    predOrders = repmat(predOrders,[fftLen/2+1,1]);
end

win = sqrt(hann(blockLen, 'periodic'));
%ffts = stft(sig,params.fs,'window',win,'overlapLength',blockLen-hopsize,'FFTLength',fftLen,'FrequencyRange','onesided');
ffts = stft(sig,win,hopsize,fftLen,params.fs);
ffts = ffts(1:fftLen/2+1,:,:);
origStft = ffts;

ffts = permute(ffts,[3 2 1]);

[numChannels, numBlocks, numFreqs] = size(ffts);
x = ffts;

Gy = zeros(numChannels, numBlocks, numFreqs);
filterCoeffs = cell(numFreqs,1);
for ff = 1:numFreqs
    predOrder = predOrders(ff);
    y = squeeze(ffts(:, :, ff));

    numSubBlocks = numBlocks - predOrder + 1;
    bufferedSubBands = zeros(numChannels, predOrder, numSubBlocks);
    for cc = 1:numChannels
        bufferedSubBands(cc, :, :)= flipud(buffer(y(cc,:), predOrder, predOrder-1, 'nodelay')); % flip time, y(t), ..., y(t-K+1)
    end
    bufferedSubBands = reshape(bufferedSubBands, numChannels*predOrder, numSubBlocks); % mono-frequent signal over time in blocks with hopsize 1, flipped in time (new to old samples)
    for iter=1:numIterations
        lambda = mean(abs(x(:, predDelay+predOrder:min(predDelay+predOrder+numSubBlocks-1, numBlocks), ff)).^2, 1); % covariance estimate via identity matrix
        lambda = movmean(lambda,covSmoothingLen,2);

        %invLambda = 1 ./ max(lambda, regulWeight); 
        invLambda = 1 ./ (lambda + regulWeight); % this regularization makes it equivalent to the "full" implementation
        sizeLambda = size(invLambda, 2);
        
        tmp = (conj(bufferedSubBands(:, 1:sizeLambda)) .* invLambda);
        R = tmp * bufferedSubBands(:, 1:sizeLambda).';
        r = tmp * y(:, predDelay+predOrder:sizeLambda+predDelay+predOrder-1).';
        g = (R + eye(numChannels*predOrder)*regulWeight*trace(R)/(numChannels*predOrder)) \ r;
        for tt = predDelay+predOrder:numBlocks              
            tmpY = reshape(y(:, tt-predDelay:-1:tt-predDelay-predOrder+1), numChannels*predOrder, 1);      
            Gy(:, tt, ff) = g.' * tmpY;
        end
        x(:, :, ff) = y - Gy(:, :, ff); % x is iteratively optimized, bufferedSubchannels are not!

    end
    filterCoeffs{ff} = reshape(g, numChannels, predOrder, numChannels);
end

dereverbStft = permute(x,[3 2 1]);
%dereverbSig = istft(dereverbStft,params.fs,'window',win,'overlapLength',blockLen-hopsize,'FFTLength',fftLen,'FrequencyRange','onesided');
%reverbSig = istft(permute(Gy,[3 2 1]),params.fs,'window',win,'overlapLength',blockLen-hopsize,'FFTLength',fftLen,'FrequencyRange','onesided');

dereverbSig = istft([dereverbStft; conj(flipud(dereverbStft(2:end-1,:,:)))], win, hopsize, 'symmetric');
GyPerm = permute(Gy,[3 2 1]);
reverbSig = istft([GyPerm; conj(flipud(GyPerm(2:end-1,:,:)))], win, hopsize, 'symmetric');

end
