function filtdata = lpfilter(data, sampling, lpcutoff)

%% filtdata = lpfilter(data, sampling, lpcutoff);
%
%Description:
%This function lowpass filters the input signal at the specified cutoff
%frequency.
%
%Parameters:
%data       -  matrix containing data where each COLUMN corresponds to a channel
%sampling   -  the sampling rate that was used in collecting the data
%lpcutoff   -  the cutoff frequency desired for the lowpass filter
%
% 05/02/2014, Shyamal Patel

%% Transpose data if channels are in the ROWS
if size(data,2) > size(data,1)
    warning('Transposing data because it appears that channels are in the ROWS')
    data = data';
end

%% Design lowpass filter with the specified cutoffs
tw = 0.5;  % width of transition band, Hz
Rp = 1;  % passband tolerance, dB 
Rs = 60;   % minimum attenuation in stopband, dB 
wp = (lpcutoff-tw/2)/(sampling/2);
ws = (lpcutoff+tw/2)/(sampling/2);

[N, Wn] = ellipord(wp,ws,Rp,Rs);
[b,a] = ellip(N,Rp,Rs,Wn);

%% Show a plot of filter
% figure,freqz(b,a),subplot(211),title('plot of lpfilter')  

%% Implement filter in non-causal manner
filtdata = filtfilt(b,a,data);