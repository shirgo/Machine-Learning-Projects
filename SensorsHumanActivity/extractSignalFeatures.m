function feat = extractSignalFeatures(at, fs)
% Extract vector of features from raw data buffer

% Initialize feature vector
feat = zeros(1,66);

% Average value in signal buffer for all three acceleration components (1 each)
feat(1:3) = mean(at,1);

% Initialize digital filter
fhp = hpfilter;

% Remove gravitational contributions with digital filter
ab = filter(fhp,at);

% RMS value in signal buffer for all three acceleration components (1 each)
feat(4:6) = rms(ab,1);

% Spectral peak features (12 each): height and position of first 6 peaks
feat(16:51) = spectralPeaksFeatures(ab, fs); % based on pwelch

% Autocorrelation features for all three acceleration components (3 each): 
% height of main peak; height and position of second peak
feat(7:15) = autocorrFeatures(ab, fs); % based on xcorr

% Spectral power features (5 each): total power in 5 adjacent
% and pre-defined frequency bands
feat(52:66) = spectralPowerFeatures(ab, fs); % based on periodogram


% --- Helper functions
function feats = spectralPeaksFeatures(x, fs)

feats = zeros(1,3*12);
N = 4096;

mindist_xunits = 0.3;
minpkdist = floor(mindist_xunits/(fs/N));

% Cycle through number of channels
nfinalpeaks = 6;
for k = 1:3
    [xpsd, f] = pwelch(x(:,k),rectwin(length(x)),[],N,fs);
    [pks,locs] = findpeaks(xpsd,'npeaks',20,'minpeakdistance',minpkdist);
    opks = zeros(nfinalpeaks,1);
    if(~isempty(pks))
        mx = min(6,length(pks));
        [spks, idx] = sort(pks,'descend');
        slocs = locs(idx);

        pkssel = spks(1:mx);
        locssel = slocs(1:mx);

        [olocs, idx] = sort(locssel,'ascend');
        opks = pkssel(idx);
    end
    ofpk = f(olocs);

    % Features 1-6 positions of highest 6 peaks
    feats(12*(k-1)+(1:length(opks))) = ofpk;
    % Features 7-12 power levels of highest 6 peaks
    feats(12*(k-1)+(7:7+length(opks)-1)) = opks;
end

function feats = autocorrFeatures(x, fs)

feats = zeros(1,9); %fix

minprom = 0.0005;
mindist_xunits = 0.3;
minpkdist = floor(mindist_xunits/(1/fs));

% Separate peak analysis for 3 different channels
for k = 1:3
    [c, lags] = xcorr(x(:,k));

    [pks,locs] = findpeaks(c,...
        'minpeakprominence',minprom,...
        'minpeakdistance',minpkdist);

    tc = (1/fs)*lags;
    tcl = tc(locs);

    % Feature 1 - peak height at 0
    if(~isempty(tcl))   % else f1 already 0
        feats(3*(k-1)+1) = pks((end+1)/2);
    end
    % Features 2 and 3 - position and height of first peak 
    if(length(tcl) >= 3)   % else f2,f3 already 0
        feats(3*(k-1)+2) = tcl((end+1)/2+1);
        feats(3*(k-1)+3) = pks((end+1)/2+1);
    end
end
    
function feats = spectralPowerFeatures(x, fs)

edges = [0.5, 1.5, 5, 10, 15, 20];

[xpsd, f] = periodogram(x,[],4096,fs); 

featstmp = zeros(5,3);

for kband = 1:length(edges)-1
    featstmp(kband,:) = sum(xpsd( (f>=edges(kband)) & (f<edges(kband+1)), :),1);
end
feats = featstmp(:);