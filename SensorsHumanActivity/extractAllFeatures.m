%% Extract features from pre-saved buffered signals

%% Load pre-buffered acceleration data (normalized)
load('BufferedAccelerations.mat','atx','aty','atz','subid','actid','fs');

% For the feature representation, expect as many rows of features
% as number of available data buffers
nFeatures = 66;
rawfeat = zeros(size(atx,1),nFeatures); 

%% Extract features from all signal buffers
tstart = tic;

% Use of parfor instead of simple for will use all available workers in
% the local parallel pool (requires Parallel Computing Toolbox)
parfor k = 1:size(atx,1)
    % Extract features for current data buffers
    rawfeat(k,:) = extractSignalFeatures([atx(k,:)', aty(k,:)', atz(k,:)'], fs); 
    fprintf('Buffer #%g\n',k)
end

disp('Done!')
fprintf('Total time elapsed: %g seconds\n', toc(tstart))

%% Save extracted features to a data file
featlabels = getFeatureNames; 

% Normalise features
fmean = mean(rawfeat,1);
fstd = std(rawfeat,[],1);
feat = bsxfun(@minus,rawfeat,fmean);
feat = bsxfun(@rdivide,feat,fstd); 

save('BufferFeaturesNew.mat','feat','fmean','fstd','featlabels','subid','actid')
