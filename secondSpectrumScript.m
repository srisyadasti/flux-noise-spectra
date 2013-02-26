function secondSpectrumScript()

% Load the data file:
s = load('SQUID2_025f_4_tc.mat');

% Time between samples of FLL (i.e. 1/sample rate). This dt is the dt used
% in computing the first spectrum.
dt1 = s.dt;
% Sampled output of FLL (in units of V):
y = double(s.y16)*s.bitSize; 

% d(flux in measured SQUID)/d(voltage output of flux-locked loop):
dPhidVFLL = 0.011776539254366;
y = y*dPhidVFLL; % y is now in units of Phi0 in the measured SQUID

% This line subtracts mean(y) from y and removes any linear trend. It is
% not necessary and the code can be run without it.
% y = detrend(y);

%% Compute the first spectrum:
% Number of averages to use for the first spectrum. This is equivalent to
% cutting the total time capture into nAvgs time segments.
nAvgs = 3200;

% Compute spectral density from time series (y), dt1, and nAvgs. Here, S1
% is the averaged power spectral density at frequencies f1. S1all contains
% all of the calculated spectral densities, essentially S1 before
% averaging, i.e. S1(i) = mean(S1all{i}).
[f1, S1, S1all] = fftSD(dt1,y,nAvgs);

figure, subplot(3,1,1)
loglog(f1,S1)
title('Power spectral density (first spectrum)')
xlabel('Frequency (Hz)')
ylabel('S_\Phi(f) (\Phi_0^2/Hz)')

%% Spectral power density versus time:

% Compute and plot data for this frequency (Hz):
f1ToPlot = 1; % <---- Change this line to look at other frequencies
% Index of frequency closest to f1ToPlot:
[~, fInd] = min(abs(f1(2:end) - f1ToPlot));
fInd = fInd + 1;

% Essentially, the "sampling" time of first spectrum power readings:
dt2 = length(y)*dt1/nAvgs;

subplot(3,1,2)
semilogy((0:length(S1all{fInd})-1)*dt2/3600, S1all{fInd})
title('Power spectral density versus time')
xlabel('Time (hr)')
ylabel(sprintf('S_\\Phi(%.2g Hz) (\\Phi_0^2/Hz)',f1(fInd)))

%% Compute the second spectrum:

% Increase the last argument (number of averages) to smooth the second
% spectrum:
[f2, S2] = fftSD(dt2, S1all{fInd}, 1);

subplot(3,1,3)
loglog(f2, S2)
title('Second spectrum')
xlabel('Frequency (Hz)')
ylabel(sprintf('S^{(2)}_\\Phi(%.2g Hz) [(\\Phi_0^2/Hz)^2/Hz]',f1(fInd)))

end