function filtdata = hpfilter(data, sampling, hpcutoff)

%% filtdata = hpfilter(data, sampling, hpcutoff);
%
%Description:
%This function highpass filters the input signal at the specified cutoff
%frequency.  
%
%Parameters:
%data       -  matrix containing data where each COLUMN corresponds to a channel
%sampling   -  the sampling rate that was used in collecting the data
%hpcutoff   -  the cutoff frequency desired for the highpass filter
%
%05/02/2014, Shyamal Patel

%% transpose data if channels are in the ROWS
if size(data,2) > size(data,1)
    warning('Transposing data because it appears that channels are in the ROWS')
    data = data';
end

%% design highpass filter to attenuate motion artifacts
tw = 1;  % width of transition band, Hz
Rp = 1;  % passband tolerance, dB 
Rs = 60;   % minimum attenuation in stopband, dB 
wp = (hpcutoff+tw/2)/(sampling/2);
ws = (hpcutoff-tw/2)/(sampling/2);

[N, Wn] = ellipord(wp,ws,Rp,Rs);
[b,a] = ellip(N,Rp,Rs,Wn,'high');

% [N, Wn] = cheb2ord(wp,ws,Rp,Rs);
% [b,a] = cheby2(N,Rs,Wn,'high');
%% Show a plot of filter
% figure,freqz(b,a),subplot(211),title('plot of hpfilter')  

%% Implement filter in non-causal manner
filtdata = filtfilt(b,a,data);