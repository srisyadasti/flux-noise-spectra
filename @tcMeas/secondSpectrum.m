function secondSpectrum(tcM, varargin)
% Function plots the second spectrum at f1.
%
% Optional parameters:
%  f1          Frequency at which to compute/plot second spectrum
%  nAvgs1      Number of averages used to compute the first spectrum
%  nAvgs2      Number of averages used to compute the second spectrum
%  sumOctave   Optionally compute the second spectrum over an octave,
%                 rather than at a single frequency f1

% Load the time series data:
tc = tcM.tcS.tc;

% Time between samples of FLL (i.e. 1/sample rate). This dt is the dt used
% in computing the first spectrum.
dt1 = tc.dt;

% Cut out the relevant portion of the time capture:
tMinInd = max(           1,  ceil((tcM.tcS.tMin+dt1)/dt1));
tMaxInd = min(length(tc.y), floor((tcM.tcS.tMax+dt1)/dt1));

% Sampled output of FLL (in units of Phi0 in the measured SQUID):
y = tc.y(tMinInd:tMaxInd) * tcM.dPhiBdVFLL;

% Clear time series data:
delete(tc), clear tc

% This line subtracts mean(y) from y and removes any linear trend. It is
% not necessary and the code can be run without it.
% y = detrend(y);

%% Interpret command-line inputs:

% Default parameters:

% Number of averages to use for the first spectrum. This is equivalent to
% cutting the total time capture into nAvgs1 time segments.
nAvgs1 = -1;
nAvgs2 = 1;

sumOctave = false;

% Compute and plot data for this frequency (Hz):
f1For2ndSpctrm = 1; % <---- Change this line to look at other frequencies

i = 1;
while i <= length(varargin) %1:nargin %#ok<*FXSET>
   switch upper(varargin{i})
      case 'NAVGS1'
         nAvgs1 = varargin{i+1}; i = i+1;
      case 'NAVGS2'
         nAvgs2 = varargin{i+1}; i = i+1;
      case 'F1'
         f1For2ndSpctrm = varargin{i+1}; i = i+1;
      case {'SUMOCTAVE','OCTAVE'}
         sumOctave = true;
      otherwise
         disp('Unrecognized command:')
         disp(varargin{i})
   end
   i = i+1;
end

if nAvgs1 == -1 % Default value, i.e. none specified
   % Choose the number of averages so that the minumum frequency of the
   % fft is close to f1For2ndSpctrm:
   if sumOctave == true
      nAvgs1 = length(y)*f1For2ndSpctrm*dt1/4;
   else
      nAvgs1 = length(y)*f1For2ndSpctrm*dt1/4;
   end
end

%% Compute the first spectrum:

% Compute spectral density from time series (y), dt1, and nAvgs1. Here, S1
% is the averaged power spectral density at frequencies f1. S1all contains
% all of the calculated spectral densities, essentially S1 before
% averaging, i.e. S1(i) = mean(S1all{i}).
[f1, S1, S1allCell] = fftSD(dt1,y,nAvgs1);
S1all = cell2mat(S1allCell);
clear S1allCell

% Cut off the high frequency portion that is highly filtered by the
% low-pass filter of the signal analyzer:
fInds = f1 <= f1(end)*800/1024;
S1all = S1all(fInds,:);
S1 = S1(fInds);
f1 = f1(fInds);

% figure
figure
subplot(3,1,1)
loglog(f1,S1)
title('Power spectral density (first spectrum)')
xlabel('Frequency (Hz)')
ylabel('S_\Phi(f) (\Phi_0^2/Hz)')

%% Spectral power density versus time:

% Index of frequency closest to f1For2ndSpctrm:
[~, fInd] = min(abs(f1(2:end) - f1For2ndSpctrm));
fInd = fInd + 1;

if sumOctave == true
   % Range of frequencies:
   f1Range = f1For2ndSpctrm <= f1 & f1 < 2*f1For2ndSpctrm;
   S1 = sum(S1all(f1Range,:),1);
else
   S1 = S1all(fInd,:);
end

% Essentially, the "sampling" time of first spectrum power readings:
dt2 = length(y)*dt1/nAvgs1;

subplot(3,1,2)
% semilogy((0:nAvgs1-1)*dt2/3600, S1) %--> crashes if length(y)/nAvgs1 isn't power of 2
semilogy((0:length(S1)-1)*dt2/3600, S1) % This one doesnt
title('Power spectral density versus time')
xlabel('Time (hr)')
ylabel(sprintf('S_\\Phi(%.2g Hz) (\\Phi_0^2/Hz)',f1(fInd)))

ylim(10.^[floor(log10(min(S1))), ceil(log10(max(S1)))])
ylims = ylim; set(gca,'yTick',10.^(log10(ylims):log10(ylims(2))))

%% Compute the second spectrum:

% Increase the last argument (number of averages) to smooth the second
% spectrum:
[f2, S2] = fftSD(dt2, S1, nAvgs2);
f2 = f2(2:end); S2 = S2(2:end);

subplot(3,1,3)
loglog(f2, S2)
xlabel('f_2 (Hz)')
ylabel(sprintf('S^{(2)}_\\Phi(%.2g Hz) [(\\Phi_0^2/Hz)^2/Hz]',f1(fInd)))

% Clare Yu plot:
% loglog(f2/f1For2ndSpctrm, S2.*f2)
% xlabel('f_2/f_1')
% ylabel('f_2S^{(2)}_\Phi(f_1,f_2) [(\Phi_0^2/Hz)^2]')

if sumOctave == true
   title(sprintf('Second spectrum of f_1 = [%g, %g) Hz', ...
      f1For2ndSpctrm*[1 2]))
else
   title(sprintf('Second spectrum of f_1 = %g Hz', f1(fInd)))
end

ylim(10.^[floor(log10(min(S2))), ceil(log10(max(S2)))])
ylims = ylim; set(gca,'yTick',10.^(log10(ylims):log10(ylims(2))))

end