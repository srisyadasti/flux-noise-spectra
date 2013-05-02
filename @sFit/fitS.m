function fitS(sf)

% disp('Running fitS...')

assert(isa(sf,'sFit'));

f = sf.s.f;
S = sf.s.S;
fMin = sf.fMin;
fMax = sf.fMax;
fitLog = sf.fitLog;
enforceWN = sf.enforceWN;
fitLorentz = sf.fitLorentz;

f = reshape(f,length(f),1);
S = reshape(S,length(S),1);

origFig = get(0,'CurrentFigure');
plotFit = false;

%% Set up fitting variables and functions:

% Cut out junk frequency components:
f = f(2:end);
S = S(2:length(f)+1);

% Look only at frequency range of interest:
S = S( f>=fMin & f<=fMax);
f = f( f>=fMin & f<=fMax);

% Normalize data to improve fitting numerics:
sy = S/mean(S);
syOrig = sy;

% Smoothed data:
pp = csaps(log(f),log(sy), 0.98);
sy = exp(fnval(pp,log(f)));

%% Set coefficients to fit:

cUsed = false(6,1);

%-----------------
% White noise term:
fixedGamma = -1;
if enforceWN, fixedGamma = 0; end

if fixedGamma == -1
    wnTerm = @(c,f) c(1) ./ f.^c(2);
    cUsed(1:2) = true;
else
    wnTerm = @(c,f) c(1) ./ f.^fixedGamma;
    cUsed(1) = true;
end

%-----------------
% Flux noise term:
% fixedAlpha = 1.2;
fixedAlpha = -1;
if fixedAlpha == -1
    fnTerm = @(c,f) c(3) ./ f.^c(4);
    cUsed(3:4) = true;
else
    fnTerm = @(c,f) c(3) ./ f.^fixedAlpha;
    cUsed(3) = true;
end

%-----------------
% Lorentzian term:
if fitLorentz
    lrntzFun = @(f0,f) 1/(pi*4) * (2*f0)./((2*pi*f).^2 + (2*f0)^2);
    lnTerm = @(c,f) c(5) * lrntzFun(c(6),f);
    cUsed(5:6) = true;
else
    lnTerm = @(c,f) 0;
end

%% Initial parameter guess:

betaS0 = zeros(6,1);

% f10Ind = find(f>max(f)/10, 1, 'first');

% fitLineHF = polyfit(log(f(end-f10Ind:end)),log(sy(end-f10Ind:end)),1);
% fitLineLF = polyfit(log(f(1:f10Ind)),log(sy(1:f10Ind)),1);

if plotFit, figure, loglog(f,sy), hold on, end

%-------------------------
% White noise term guess:
inds = log(f) > log(max(f)) - diff(log([min(f),max(f)]))/10;
if fixedGamma ~= -1
    betaS0(1) = ...
        nlinfit(f(inds), log(sy(inds)), @(c,f) log(wnTerm(c,f)), ...
        sy(end)/f(end)^fixedGamma);
else
    betaS0(1:2) = ...
        nlinfit(f(inds), log(sy(inds)), @(c,f) log(wnTerm(c,f)), ...
        [sy(end), fixedGamma]);
    
    if betaS0(2) > 0.3
        disp('Bad white noise term fit')
        betaS0(2) = 0.1;
        betaS0(1) = sy(end) * f(end)^betaS0(2);
    end
end
if plotFit, loglog(f, wnTerm(betaS0,f), 'r'), end

%-------------------------
% Flux noise term guess:

% Look fit only the first 'a' of frequency range:
indsFun = @(a) log(f) < log(max(f)) - diff(log([min(f),max(f)]))*(1-a);
inds = indsFun(0.3);

if fixedAlpha ~= -1
    betaS0(3) = ...
        nlinfit(f(inds), log(sy(inds)), @(c,f) log(fnTerm([0 0 c],f)), ...
        sy(1)/f(1)^fixedAlpha);
else
    betaS0(3:4) = ...
        nlinfit(f(inds), log(sy(inds)), @(c,f) log(fnTerm([0 0 c],f)), ...
        [sy(1), fixedAlpha]);
    if abs(trapz(log(f),log(sy) - ...
            log(wnTerm(betaS0,f) + fnTerm(betaS0,f)))) > 8
        inds = indsFun(0.6);
        betaS0(3:4) = ...
            nlinfit(f(inds), log(sy(inds)), ...
            @(c,f) log(fnTerm([0 0 c],f)), [sy(1), fixedAlpha]);
    end
end
if plotFit, loglog(f, fnTerm(betaS0,f), 'r'), end

% Check fit:
% disp(abs(trapz(log(f),log(sy) - log(wnTerm(betaS0,f) + fnTerm(betaS0,f)))))

%-------------------------
% Lorentzian term guess:
    
if fitLorentz
    A = false(nnz(cUsed(1:4)),6);
    j = 1:6; j = j(cUsed(1:4));
    for i = 1:nnz(cUsed(1:4)), A(i,j(i)) = true; end
    A = A(:,1:4);
    
    fun = @(c,f) wnTerm(c,f) + fnTerm(c,f);
    fitFun = @(c,f) wnTerm(c'*A,f) + fnTerm(c'*A,f);
    
    [betaS0,r] = nlinfit(f, log(sy), ...
        @(c,f) log(fitFun(c,f)), betaS0(cUsed(1:4)) );
    betaS0 = A'*betaS0;
    if any(imag(betaS0)), disp('Bad initial Lorentzian fit'), end
    
    if plotFit, loglog(f, wnTerm(betaS0,f) + fnTerm(betaS0,f), 'c'), end
    
    syLor = sy - fun(betaS0,f);
    fitUnder = find(syLor<0);
    [~, LorStartInd] = max(diff(fitUnder));
    
    LorInds = fitUnder(LorStartInd)+1 : fitUnder(LorStartInd+1)-1;

    fLor  =     f(LorInds);
    syLor = syLor(LorInds);
    
%     figure, loglog(f,sy)
%     hold on
%     loglog(f,fun([betaS0;0;0],f),'r')
%     loglog(f, betaS0(1) * f.^-betaS0(2),'c')
%     loglog(f, betaS0(3) * f.^-betaS0(4),'c')
%     title(sprintf('T = %.2f', evalin('caller','tcM1.T')))
    
%     figure, semilogx(f,(sy-fun(betaS0,f))./fun(betaS0,f),'r')
%     hold on, semilogx(fLor,(syLor)./fun(betaS0,fLor),'b')
    
    lastwarn('');
    warning('off','stats:nlinfit:ModelConstantWRTParam');
    warning('off','stats:nlinfit:IllConditionedJacobian');
    warning('off','stats:nlinfit:IterationLimitExceeded');
    c1 = nlinfit(fLor,log(syLor), @(c,f) log(c(1)*lrntzFun(c(2),fLor)),...
        [100 200]);
    warning('on','stats:nlinfit:ModelConstantWRTParam');
    warning('on','stats:nlinfit:IllConditionedJacobian');
    warning('on','stats:nlinfit:IterationLimitExceeded');
    [~, msgid] = lastwarn;
    if ~isempty(msgid) || c1(2) > 1e3 %|| c1(1)/c1(2) < 0.1 %|| c1(1) < 10
%         badLor = true;
%         fitLorentz = false;
        betaS0(5:6) = 0;
        cUsed(5:6) = false;
    else
        if all(c1<0), c1 = -c1; end
%         betaS0(5:6) = c1;
        betaS0(6) = pi*mean(fLor);
        betaS0(5) = 16*pi*mean(syLor)*betaS0(6);
%         disp(betaS0(5:6)./c1')
    end
end

%% Define the function:

fitGood = false;

while ~fitGood

    A = false(nnz(cUsed),6);
    j = 1:6; j = j(cUsed);
    for i = 1:nnz(cUsed), A(i,j(i)) = true; end
    
    fun = @(c,f) wnTerm(c,f) + fnTerm(c,f) + lnTerm(c,f);
    fitFun = @(c,f) wnTerm(c'*A,f) + fnTerm(c'*A,f) + lnTerm(c'*A,f);
    
    % Fit the function:
    
    if fitLog
        [betaS,r,~,COVB] = nlinfit(f, log(sy), ...
            @(c,f) log(fitFun(c,f)), betaS0(cUsed));
    else
        [betaS,r,~,COVB] = nlinfit(f, sy, ...
            @(c,f) fitFun(c,f), betaS0(cUsed));
    end
    
    betaS = A'*betaS;
    if all(cUsed(5:6)) && (any(betaS(5:6)./betaS0(5:6) > 10) || ...
            any(betaS(5:6)./betaS0(5:6) < 0.1))
%         badLor = true;
%         fitLorentz = false;
        betaS(5:6) = NaN;
        cUsed(5:6) = false;
    else
        fitGood = true;
    end

end
  
%% Compute the confidence intervals for each of the coefficients:
if any(imag(betaS(cUsed)))
    % Can't compute CI, just make the errors infinite:
    betaSerr = Inf*ones(size(betaS(cUsed)));
else
    betaSerr = diff(...
        nlparci(betaS(cUsed),r,'covar',COVB,'alpha',0.68268), 1,2)'/2;
end

% Throw away small imaginary components:
if any(abs(real(betaS)./imag(betaS)) < 1e5)
    warning('MATLAB:fitSlope:imagCoeffs',...
        ['Some fit coefficients have large imaginary components.\n',...
        sprintf('Max ratio is %g',1/min(abs(real(betaS)./imag(betaS))))])
end
betaS = real(betaS);

%% Restore missing fit coefficients:

% betaS = A'*betaS;
betaSerr = A'*reshape(betaSerr,nnz(cUsed),1);

if betaS(4) < betaS(2)
    betaS(1:4) = betaS([3 4 1 2]);
end

if all(betaS(5:6) < 0)
    betaS(5:6) = -betaS(5:6);
elseif xor(betaS(5) < 0, betaS(6) < 0)
    warning('fitSlope:OneLorentzianCoefficientNegative',...
        'One of the Lorentzian coefficients is negative.')
end

if fixedGamma ~= -1, betaS(2) = fixedGamma; end
if fixedAlpha ~= -1, betaS(4) = fixedAlpha; end

%% Plotting helper functions

if false
    figure, loglog(f,syOrig)
    hold on
    loglog(f,fun(betaS0,f),'r')
    loglog(f,fun(betaS,f),'k')
    loglog(f,betaS0(3) * f.^-betaS0(4),'c')
    loglog(f,betaS0(1) * f.^-betaS0(2),'c')
    if fitLorentz
        loglog(f,abs(betaS0(5) * lrntzFun(betaS0(6),f) ),'r')
        loglog(f,abs(betaS(5) * lrntzFun(betaS(6),f) ),'k')
        
        figure
        loglog(fLor,syLor)
        hold on
        
        syLor = sy - wnTerm(betaS,f) - fnTerm(betaS,f);
        fitUnder = find(syLor<0);
        [~, LorStartInd] = max(diff(fitUnder));
        
        LorInds = fitUnder(LorStartInd)+1 : fitUnder(LorStartInd+1)-1;
        fLor  =     f(LorInds);
        syLor = syLor(LorInds);
        
        loglog(fLor,betaS0(5)*lrntzFun(betaS0(6),fLor),'r')
        loglog(fLor,sy(LorInds) - wnTerm(betaS,fLor) - ...
            fnTerm(betaS,fLor),'k')
        loglog(fLor,betaS(5)*lrntzFun(betaS(6),fLor),'g')
        title(sprintf('T = %.2f', evalin('caller','tcM1.T')))
    end
end

%% Restore units:

betaS([1 3 5]) = betaS([1 3 5]) * mean(S);
betaSerr([1 3 5]) = betaSerr([1 3 5]) * mean(S);

%% Return variables:

sf.coeff = reshape(betaS,1,length(betaS));
sf.coeffErr = reshape(betaSerr,1,length(betaSerr));
sf.SyFitFun = @(f) fun(betaS,f);

set(0,'CurrentFigure',origFig)

end