function [stftBfd, bfWeights] = applyBeamformerStft(sigStft, steeringVecs, bfType, regulConst, noisePsdMtx)
% Thomas Deppisch, 2023
arguments
    sigStft (:,:,:) % numFrequencies (singleSided) x numBlocks x numChannels
    steeringVecs (:,:) % numChannels x numFrequencies or numChannels x 1
    bfType {mustBeMember(bfType,{'delayAndSum','delayAndSumNormd','MPDR','MVDR'})} = 'delayAndSum';
    regulConst (1,1) = 1e-4;
    noisePsdMtx = []; % 3 dimensional matrix: numChannels x numChannels x numFrequencies
end

[numFrequencies, numBlocks, numChannels] = size(sigStft);
if size(steeringVecs,2) == 1
    steeringVecs = repmat(steeringVecs, [1 numFrequencies]);
end

stftBfd = zeros(numFrequencies, numBlocks); % median doa
bfWeights = zeros(numChannels, numFrequencies);

regulConstMpdr = regulConst * max(sum(abs(sigStft).^2,[2,3]));

if nargin > 4 && ~isempty(noisePsdMtx)
    if strcmp(noisePsdMtx, 'identity')
        noisePsdMtx = repmat(eye(numChannels), [1 1 numFrequencies]);
    end
end

for ii = 1:numFrequencies
    if strcmp(bfType, 'delayAndSum') % Van Trees eq. 2.32
        bfWeights(:,ii) = 1/numChannels * steeringVecs(:,ii);
        stftBfd(ii,:) = bfWeights(:,ii)' * squeeze(sigStft(ii,:,:)).';
    elseif strcmp(bfType, 'delayAndSumNormd') % this is equivalent to MVDR with identity noise PSD
        bfWeights(:,ii) = steeringVecs(:,ii) / (steeringVecs(:,ii)' * steeringVecs(:,ii) + regulConst * max(sum(abs(steeringVecs).^2,2)));
        stftBfd(ii,:) = bfWeights(:,ii)' * squeeze(sigStft(ii,:,:)).';
    elseif strcmp(bfType, 'MPDR') % Van Trees
        Rxx = squeeze(sigStft(ii,:,:))' * squeeze(sigStft(ii,:,:));
        %regul = regulConst * trace(Rxx) * eye(numChannels);
        RxxRegul = Rxx + regulConstMpdr * eye(numChannels);
        bfWeights(:,ii) = (RxxRegul \ steeringVecs(:,ii)) / (steeringVecs(:,ii)' / RxxRegul * steeringVecs(:,ii));
        stftBfd(ii,:) = bfWeights(:,ii)' * squeeze(sigStft(ii,:,:)).';
    elseif strcmp(bfType, 'MVDR') % Van Trees, ch. 6
        bfWeights(:,ii) = (noisePsdMtx(:,:,ii) \ steeringVecs(:,ii)) / (steeringVecs(:,ii)' / noisePsdMtx(:,:,ii) * steeringVecs(:,ii) + regulConst * max(sum(abs(steeringVecs).^2,2)));
        stftBfd(ii,:) = bfWeights(:,ii)' * squeeze(sigStft(ii,:,:)).';
    end
end


