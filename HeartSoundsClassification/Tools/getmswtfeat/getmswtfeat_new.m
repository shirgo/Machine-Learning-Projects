% GETMSWTFEAT Gets the Multiscale Wavelet Transform features, these
% include: Energy, Variance, Standard Deviation, and Waveform Length
% feat = getmswtfeat(x,winsize,wininc,SF)
% ------------------------------------------------------------------
% The signals in x are divided into multiple windows of size
% "winsize" and the windows are spaced "wininc" apart.
% Inputs
% ------
%    x: 		1D signal
% Outputs
% -------
%    feat:     WT features organized as [Energy, Variance, Waveform Length, Entropy]

% Example
% -------
% feat = getmswtfeat(rand(1024,1))
% Assuming here rand(1024,1) (this can be any one dimensional signal,
% for example EEG or EMG) is a one dimensional signal sampled at 32
% for 32 seconds only. Utilizing a window size of 128 at 32 increments,
% features are extracted from the wavelet tree.
% I assumed 10 decomposition levels (J=10) below in the code.
% For a full tree at 10 levels you should get 11 features
% as we have decided to extract 4 types of features then we get 11 x 4 =44
% features.
% =========================================================================
% Multiscale Wavelet Transform feature extraction code by Dr. Rami Khushaba
% Research Fellow - Faculty of Engineering and IT
% University of Technology, Sydney.
% Email: Rami.Khushaba@uts.edu.au
% URL: www.rami-khushaba.com (Matlab Code Section)
% last modified 29/08/2012
% last modified 09/02/2013

% =========================================================================
% Modified by Shyamal Patel
% last modified 11/18/2016

function feat = getmswtfeat_new(x)
[cfs,longs] = wavedec(x,10,'db4');
level = length(longs)-2;

dim = 1;
if dim==1
    cfs1 = cfs';
    longs1 = longs';
end

numOfSIGs  = size(cfs1,1);
num_CFS_TOT = size(cfs1,2);
absCFS   = abs(cfs1);
cfs_POW2 = absCFS.^2;
Energy  = sum(cfs_POW2,2);
percentENER = 0*ones(size(cfs_POW2));
notZER = (Energy>0);
percentENER(notZER,:) = 100*cfs_POW2(notZER,:)./Energy(notZER,ones(1,num_CFS_TOT));

%% Pre-define and allocate memory
tab_ENER = zeros(numOfSIGs,level+1);
tab_VAR = zeros(numOfSIGs,level+1);
% tab_STD = zeros(numOfSIGs,level+1);
tab_WL = zeros(numOfSIGs,level+1);
tab_entropy = zeros(numOfSIGs,level+1);

%% Feature extraction section
st = 1;
for k=1:level+1
    nbCFS = longs1(k);
    en  = st+nbCFS-1;
    tab_ENER(:,k) = mean(percentENER(:,st:en),2);%.*sum(abs(diff(absCFS0(:,st:en)')'),2); % energy per waveform length
    tab_VAR(:,k) = var(percentENER(:,st:en),0,2); % variance of coefficients
    %     tab_STD(:,k) = std(percentENER(:,st:en),[],2); % standard deviation of coefficients
    tab_WL(:,k) = sum(abs(diff(percentENER(:,st:en)').^2))'; % waveform length
    percentENER(:,st:en) = percentENER(:,st:en)./repmat(sum(percentENER(:,st:en),2),1,size(percentENER(:,st:en),2));
    tab_entropy(:,k) = -sum(percentENER(:,st:en).*log(percentENER(:,st:en)),2)./size(percentENER(:,st:en),2);
    st = en + 1;
end
feat =([log1p([tab_ENER tab_VAR  tab_WL]) tab_entropy]);