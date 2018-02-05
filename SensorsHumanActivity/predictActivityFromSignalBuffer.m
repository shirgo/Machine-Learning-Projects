function predictedActid = predictActivityFromSignalBuffer(at, fs, fmean, fstd)
% predictActivityFromSignalBuffer predicts an activity ID from the (Nx3)
% input acceleration buffer at. fs is the sample frequency used for at,
% while fmean and fstd are the pre-computed feature normalization
% parameters

% Extract feature vector
rawf = featuresFromBuffer(at, fs);
f = (rawf-fmean)./fstd;

% Classify with bagged trees classifier
CompactMdl = loadCompactModel('trainedModel');
predictedActid = predict(CompactMdl,f);

end