function fftTC( tcS )

% Perform an fft on the tcS object.

%% Extract relevant data from tcS:
tMin = tcS.tMin;
tMax = tcS.tMax;

autoStitch = tcS.autoStitch;
minAvgs = tcS.minAvgs;
sFactor = tcS.sFactor;

fCuts = tcS.fCuts;
avgs = tcS.avgs;

tc = timeCapture(tcS.filename);

%% Process the time capture data:

% Truncate the time capture:
dt = tc.dt;
tMinInd = max(           1,  ceil((tMin+dt)/dt));
tMaxInd = min(length(tc.y), floor((tMax+dt)/dt));
y = tc.y( tMinInd:tMaxInd );

delete(tc)
clear tc

%% Adjust dt

% The "maximum" frequency specified when setting the signal analyzer is
% actually less than the real maximum frequency of the fft because the
% signal analyzer oversamples by a factor 1028/800, so for purposes of
% bookkeeping we set fMax equal to the value that we actually set when
% acquiring the time capture. We will later discard everything above fMax
% because it is strongly rolled off by the low-pass filter.
fMax = round(1/(2*dt) * 800/1024);

% dt isn't saved with the necessary precision, so just assume that fMax is
% an integer and adjust dt so that it's right.
dt = 800 / (1024 * 2 * fMax);

%% Calculate avgs and fCuts if autoStitch is on:

if autoStitch
    fMax = 1/(2*dt) * 800/1024; % maximum frequency of FFT
    avgsMax = length(y)/1024;   % maximum number of averages
    
    % number of frequency cuts:
    num_fCuts = floor(log(avgsMax/minAvgs) / log(2^sFactor));
    
    % Calculated averages and fCuts:
    avgs = [floor(avgsMax./2.^(sFactor*(num_fCuts:-1:1))), avgsMax];
    fCuts = (fMax/50) ./ 2.^(sFactor*(num_fCuts:-1:1));
    
    tcS.avgs = avgs;
    tcS.fCuts = fCuts;
end

%% Check that fCuts is sorted correctly:
assert(~any(diff(fCuts) < 0), ...
    'tcSpectrum:fftTC:fCuts_not_sorted', ...
    'fCuts is not sorted properly (must be increasing)')

if length(fCuts) + 1 < length(avgs)
    warning('tcSpectrum:fftTC:fCuts_avgs_length_mismatch', ...
        ['More FFT segments than frequency cuts.\n', ...
        'Ignoring extra high frequency segments.'])
end

if length(fCuts) + 1 > length(avgs)
    warning('tcSpectrum:fftTC:fCuts_avgs_length_mismatch', ...
        ['More frequency cuts than FFT segments.\n', ...
        'Ignoring extra high frequency cuts.'])
end

%% Initialize variables:

% Determine the number of FFT segments and trim variables:
nFFTsegs = min( length(fCuts)+1, length(avgs) );
fCuts = fCuts(1:nFFTsegs-1);
avgs = avgs(1:nFFTsegs);

% Set FFT frequency boundaries:
fCuts = [0 fCuts inf];

% Combined spectral power and freqency arrays:
fCmb = []; SCmb = []; SSCmb = {};

%% Loop over FFT stitches:

for FFTnum = 1:nFFTsegs
    % Set block size to achieve specified minimum number of averages that
    % also a multiple of 2:
    blkSzi = 2^(nextpow2((length(y)+1)/avgs(FFTnum))-1);
    
    % Define frequency array (Hz)
    f = (0:blkSzi/2)' / (dt * blkSzi);
    
    % Frequency indices where stitch points occur:
    f1Ind = find( f >= fCuts(FFTnum),   1,'first');
    f2Ind = min( find( f  < fCuts(FFTnum+1), 1,'last'),...
        find( f  <= f(end)*800/1024, 1,'last'));
    
    % Initialize averaging array:
    SAvg = zeros(blkSzi/2+1,1);
    
    SAll = zeros(f2Ind - f1Ind + 1, floor(length(y)/blkSzi));
    
    %% Loop over FFT averages
    for avgNum = 1:length(y)/blkSzi
        % Windowed time:
        wt = y((avgNum-1)*blkSzi+1 : avgNum*blkSzi);
%         wt = detrend(wt);
%         wt = wt - mean(wt);
%         wt = hamming(length(wt)) .* wt / sqrt(mean(hamming(length(wt)).^2));
%         wt = hann(length(wt)) .* wt / sqrt(mean(hann(length(wt)).^2));
        
        % FFT of windowed time:
        fftwt = fft(wt)/blkSzi;
        
        % Extract unique data:
        fftwt = fftwt(1:blkSzi/2+1);
        
        % Calculate the temporary amplitude spectral density:
        S12 = abs(fftwt);
        
        % Because we threw out the symmetric points, we must conserve power
        % (the dc component is not symmetric and doesn't need the sqrt2 )
        S12(2:end-1) = S12(2:end-1)*sqrt(2);
        
        % Amplitude spectral density:
        % (Equivalent statement: S12 = S12*sqrt(dti*blkSzi);)
        S12 = S12/sqrt(f(2));
        
        % Power spectral density:
        S = S12.^2;
        
        % Store fft information for each average:
        SAll(:,avgNum) = S(f1Ind:f2Ind);
        
        % Compute moving weighted average:
        SAvg = (SAvg*(avgNum-1) + S)/avgNum;
    end
    
    % Remove higher frequency because of oversampling of the signal
    % analyzer:
    SAvg = SAvg(f <= f(end)*800/1024);
    f    =    f(f <= f(end)*800/1024);
    
    % Stitch together FFTs:
    SCmb  = [SCmb; SAvg(f1Ind:f2Ind)];
    fCmb  = [fCmb;    f(f1Ind:f2Ind)];
    SSCmb = [SSCmb; num2cell(SAll,2)];
    
    clear SAll % Needed to plug memory leak
end % end averaging

%% Calculate the drift:

blkSzi = 2^(nextpow2( (length(y)+1) / min(avgs) ) - 1);

ti = dt*(0:blkSzi*min(avgs)-1)';
tDataFiti = y(1:length(ti));
cFit = [ti, ones(size(tDataFiti))] \ tDataFiti;
drift = cFit(1) * 3600; % drift in V/hr

SDrift = @(f) (blkSzi * dt / 2) * ((drift / 3600) ./ (pi*f)).^2;

%% Clean up (I don't know why this is necessary to free up memory):

clear y ti tDataFiti % Needed to plug memory leak

%% Return variables:

% This code stores info for calculating the second spectra, but uses a lot
% more memory:
% tcS.s = spectrum(fCmb, SCmb, SSCmb);

% Lower memory version:
clear SSCmb % Needed to plug memory leak
tcS.s = spectrum(fCmb, SCmb);

tcS.drift = drift;
tcS.SDrift = SDrift;

end

