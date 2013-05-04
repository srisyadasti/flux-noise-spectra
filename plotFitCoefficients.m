function [tcM, tcMall, tcMinfo] = plotFitCoefficients(tcMall)

% Check that tcMall is specified:
% narginchk(1, 1)

% tcMall should be an array of objects of type tcMeas:
assert(isa(tcMall,'tcMeas'));

tcMall = spectraFiles(tcMall);
tcM = tcMall;
conditionTCs(tcMall);

%% Error checking:

assert(length([tcM.T]) == length(tcM));
assert(length([tcM.flux]) == length(tcM));
assert(length([tcM.vout]) == length(tcM));
assert(length([tcM.fMax]) == length(tcM));
assert(length([tcM.SQUID]) == length(tcM));
assert(length([tcM.startTime])/6 == length(tcM));

%% Specify settings:
fMin = 0.1;
fMax = 350;

fitLorentz = false;
enforceWN = true;

% xAxis = 'SQUID';
% xAxis = 'T';
% xAxis = 'RW';
% xAxis = 'logW';

avgOn = false;

f0 = 1; % A^2 = S_Phi(f0)

%% Pick time captures for tcM:

% Choose the run:
% tcM = tcM(cellStrToInd({tcMall.runName},'NIST1_c1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'NIST1_c4'));
% tcM = tcM(cellStrToInd({tcMall.runName},'NIST2_c1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'UIUCe452_c1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'UIUCe455_c1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'Jeff1_c1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'MIT5B3_c1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'MIT5C3_c1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'UIUC1_c1'));

% Gold-capped SQUIDs:
% tcM = tcM(cellStrToInd({tcMall.runName},'Chris1_c1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'Chris2_c2'));
% tcM = tcM(cellStrToInd({tcMall.runName},'Chris3_c1'));

% Silicon nitride:
% tcM = tcM(cellStrToInd({tcMall.runName},'NIST_SiNx1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'NIST_SiNx2'));
% tcM = tcM(cellStrToInd({tcMall.runName},'NIST_SiNx3'));
% tcM = tcM(cellStrToInd({tcMall.runName},'UIUC_NbNx1'));

% tcM = tcM(cellStrToInd({tcMall.runName},'e523E'));
% tcM = tcM(cellStrToInd({tcMall.runName},'NIST3_c1'));
% tcM = tcM(cellStrToInd({tcMall.runName},'e543B'));
% tcM = tcM(cellStrToInd({tcMall.runName},'e544A'));
% tcM = tcM(cellStrToInd({tcMall.runName},'e544C'));
% tcM = tcM(cellStrToInd({tcMall.runName},'P77A'));
% tcM = tcM(cellStrToInd({tcMall.runName},'P77B'));
% tcM = tcM(cellStrToInd({tcMall.runName},'SiNx_bot'));
% tcM = tcM(cellStrToInd({tcMall.runName},'SiNx_topbot'));
% tcM = tcM(cellStrToInd({tcMall.runName},'epiAl_SiNx'));
% tcM = tcM(cellStrToInd({tcMall.runName},'SGS-BD'));
tcM = tcM(cellStrToInd({tcMall.runName},'SGS-AC'));

% tcM = tcMall(cellStrToInd({tcMall.runName},'NIST1_c1') | ...
%     cellStrToInd({tcMall.runName},'NIST1_c4'));

% tcM = tcM(~cellfun(@isempty,strfind({tcM.filename},'junk')));

tcM = tcM([tcM.tcFileSize] > 50e6); % tc filesize greater than 50MB

% tcM = tcM([tcM.T] <= 1.6);

tcM = tcM([tcM.flux] ~= 0 & ~isnan([tcM.flux]) & [tcM.vout]>0 & ...
    [tcM.vin]>0);
% tcM = tcM([tcM.flux] ~= 0.125);
tcM = tcM([tcM.flux] == 0.25);

% tcM = tcM([tcM.vout] > 0);

% tcM = tcM([tcM.totalTime] >= 3200*0.99); % Only hour-long captures

tcM = tcM(~[tcM.fluxModOn]);

tcM = tcM([tcM.fMax] == 400);
% tcM = tcM([tcM.fMax] < 1e3);

% tcM = tcM([tcM.SQUID] == 1);
% tcM = tcM([tcM.SQUID] == 1 | [tcM.SQUID] == 2 | [tcM.SQUID] == 5);
% tcM = tcM([tcM.SQUID] ~= 1);

% tcM = tcM(abs([tcM.R] - 5) < 0.1);
% tcM = tcM([tcM.R] > 0);
% tcM = tcM([tcM.R] ~= 10);

% dates = datenum(vertcat(tcM.startTime));

% tcM = tcM(dates > datenum([2011 6 17 0 0 0])); % flux modulation scheme
% 
% tcM = tcM(~( dates < datenum([2011 5 3 8 0 0]) & ...
%     dates > datenum([2011 5 2 20 0 0]) & ...
%     [tcM.SQUID]' == 2 & strcmp({tcM.runName}','NIST1_c1')) );
% 
% % Pick the lower bias voltage:
% tcM = tcM(~([tcM.SQUID] == 3 & [tcM.T] == 0.25 & [tcM.R] ~= 5.01 & ...
%     strcmp({tcM.runName},'NIST1_c1')));
% tcM = tcM(~([tcM.SQUID] == 4 & [tcM.T] == 0.1 & [tcM.R] ~= 5.01 & ...
%     strcmp({tcM.runName},'NIST1_c1')));

%% Remove crap time captures:

tcM = tcM( ~(strcmp({tcM.runName},'NIST1_c4') & [tcM.T] <= 1.5) );
tcM = tcM( ~(strcmp({tcM.runName},'NIST1_c4') & [tcM.SQUID] == 1) );

% White noise is all messed up:
tcM = tcM(~(([tcM.SQUID] == 2 | [tcM.SQUID] == 5 | [tcM.SQUID] == 6) & ...
    [tcM.T] == 1.85 & strcmp({tcM.runName},'NIST1_c1') ));
tcM = tcM(~(([tcM.SQUID] == 2 | [tcM.SQUID] == 3) & ...
    [tcM.T] == 2.2 & strcmp({tcM.runName},'NIST1_c1') ));
% Someone left on the dI/dPhi modulation signal:
tcM = tcM(~([tcM.SQUID] == 2 & ...
    [tcM.T] == 1.0 & strcmp({tcM.runName},'NIST1_c4') ));
% SQUID 6 is jacked up:
tcM = tcM(~([tcM.SQUID] == 6 & strcmp({tcM.runName},'NIST2_c1') ));
% A big Lorentzian bump:
% tcM = tcM(~([tcM.SQUID] == 1 & ...
%     [tcM.T] >= 1.5 & strcmp({tcM.runName},'NIST1_c4') ));
tcM = tcM(~([tcM.SQUID] == 2 & ...
    [tcM.T] <= 0.4 & strcmp({tcM.runName},'Chris1_c1') ));
% Huge noise for some reason:
tcM = tcM(~([tcM.SQUID] == 5 & ...
    [tcM.T] == 0.2 & strcmp({tcM.runName},'NIST1_c4') ));
% Too high in temperature:
tcM = tcM(~([tcM.T] > 0.3 & strcmp({tcM.runName},'Jeff1_c1') ));
% Paramagnetic noise?
tcM = tcM(~([tcM.T] == 0.05 & strcmp({tcM.runName},'UIUCe455_c1') ));
% Too high in temperature:
tcM = tcM(~([tcM.T] < 0.1 & strcmp({tcM.runName},'MIT5B3_c1') ));

%% Automatic geometry settings:

runNames = unique({tcM.runName});
if length(runNames) == 1
    switch runNames{1}
        case 'MIT5B3_c1'
            RW = [12 6 3 1.5 1.5 1.5]/0.5;
        case 'MIT5C3_c1'
            R = [24 12 6 3 1.5 1.5];
            W = [8 4 2 1 0.5 0.5];
            RW = R./W;
            logW = log10(W);
        case 'Chris1_c1'
            RW = ones(6,1) * 5/3;
            logW = ones(6,1) * log10(3);
        case {'NIST1_c1','NIST1_c4'}
            R = [185 105 65 45 32.5 25];
            W = [160 80 40 20 10 5];
            RW = R./W;
        case {'NIST3_c1'}
            R = [265 145 85 55 40 30];
            W = [240 120 60 30 15 7.5];
            RW = R./W;
    end
end

%% Get coefficients for all time captures:
if isempty(tcM)
    disp('No time captures found...')
    return
end

for i = 1:length(tcM)
    
    
    if  any([tcM.flux] == 0) || any(isnan([tcM.flux]))
        tcM(i).yUnit = 'Ii';
    else
        tcM(i).yUnit = 'phi';
    end
    
    % Determine fMin:
    if tcM(i).T >= 1.5, tcM(i).sf.fMin = 1;
    else tcM(i).sf.fMin = fMin; end
    
    % For NIST1_c4:
    if strcmpi(tcM(i).runName,'NIST1_c4') && (tcM(i).T >= 1.5 || ...
            tcM(i).SQUID == 1)
        tcM(i).sf.fMin = 1;
    end
    % For NIST3_c1:
    if strcmpi(tcM(i).runName,'NIST3_c1')
        if tcM(i).T >= 1.4
            tcM(i).sf.fMin = 1;
        elseif tcM(i).T >= 1
            tcM(i).sf.fMin = 0.1;
        end
    end
    
    tcM(i).s.noNoise = true;
    tcM(i).sf.fMin = fMin;
    tcM(i).sf.fMax = fMax;
    tcM(i).sf.fitLorentz = fitLorentz;
    tcM(i).sf.enforceWN = enforceWN;   
    tcM(i).sf.updatedFit = false;
end

coeff = vertcat(tcM.coeff);
% coeff = reshape(coeff,6,length(coeff)/6)';
% coeff(coeff == 0) = NaN;

T = [tcM.T]';
SQUID = [tcM.SQUID]';
C2 = coeff(:,1);
gam = coeff(:,2);
A2 = coeff(:,3);
alph = coeff(:,4);
% Lamp = coeff(:,5);
% Lfreq = coeff(:,6);

% Struct to export:
tcMinfo = struct('runName',runNames, 'T',T, 'SQUID',SQUID, 'C2',C2, ...
    'gamma',gam, 'A2',A2, 'alpha',alph);

if exist('RW',  'var'), tcMinfo.RW   = RW;   end
if exist('logW','var'), tcMinfo.logW = logW; end

%% Ghetto hack that I used once but never again:

% if false % remove spectra with high white noise:
%     inds = C2*1e12 < 0.1 + [tcM.T]'/5;
%     T = T(inds);
%     SQUID = SQUID(inds);
%     C2 = C2(inds);
%     gam = gam(inds);
%     A2 = A2(inds);
%     alph = alph(inds);
% end

%% Determine x-axis:

if length(unique(T)) == 1, singleT = true;
else singleT = false; end

if length(unique(SQUID)) == 1, singleSQUID = true;
else singleSQUID = false; end

% if length(unique({tcM.runName})) == 1, singleRun = true;
% else singleRun = false; end

if ~exist('xAxis','var')
    if ~singleT && ~singleSQUID
        % xAxis = 'SQUID';
        xAxis = 'T';
        % xAxis = 'RW';
        % xAxis = 'logW';
    elseif singleT && ~singleSQUID
        xAxis = 'SQUID';
        % xAxis = 'logW';
        % xAxis = 'RW';
    elseif ~singleT && singleSQUID
        xAxis = 'T';
    end
end

% Determine x-axis:
switch xAxis
    case 'SQUID'
        xToPlot = SQUID;
        xlabelStr = 'SQUID';
        [b, ~, n] = unique(T);
        xAxisScale = 'linear';
    case 'RW'
        xToPlot = RW(SQUID);
        xlabelStr = 'R/W';
        [b, ~, n] = unique(T);
        xAxisScale = 'log';
    case 'logW'
        xToPlot = W(SQUID);
        xlabelStr = 'W ({\mu}m)';
        [b, ~, n] = unique(T);
        xAxisScale = 'log';
    case 'T'
        xToPlot = T;
        xlabelStr = 'T [K]';
        [b, ~, n] = unique(SQUID);
        xAxisScale = 'log';
        % xAxisScale = 'linear';
end

switch xAxisScale
    case 'linear'
        plotYlog = @semilogy;
        plotYlin = @plot;
    case 'log'
        plotYlog = @loglog;
        plotYlin = @semilogx;
end

%% Plot figures:

colors = lines(length(b));
legends = cell(length(b),1);

figure
for i = 1:length(b)
%     legends{i} = b{i};
    legends{i} = sprintf('%g',b(i));
    
    % Indices of data points to plot for this iteration of for loop:
    indsA = A2>0 & n==i;
    
    A2i = A2(indsA);
    alphi = alph(indsA);
    xToPloti = xToPlot(indsA);
    
    if avgOn
        [xToPloti, ~, navg] = unique(xToPloti);
        A2Avg = NaN(size(xToPloti));
        alphAvg = NaN(size(xToPloti));
        for j = 1:length(xToPloti)
            A2Avg(j) = mean(A2i(navg==j));
            alphAvg(j) = mean(alphi(navg==j));
        end
        A2i = A2Avg;
        alphi = alphAvg;
    end
    
    % Plot A:
    subplot(2,2,1)
%     plotYlog(xToPloti, A2i*1e12.*f0.^-alphi, '.-','color',colors(i,:),...
%         'MarkerSize',10)
%     hold on
%     xlabel(xlabelStr), ylabel('A^2 [(\mu\Phi_0)^2/Hz]')
    
    % Plot <Phi^2>
    plotYlog(xToPloti, A2i*1e12.*(10.^(9*(1-alphi))...
    -10.^(-4.*(1-alphi)))./(1-alphi), '.-','color',colors(i,:),...
         'MarkerSize',10)
    hold on
    xlabel(xlabelStr), ylabel('\langle\Phi^2\rangle [(\mu\Phi_0)^2]')
    continue
    
    % Plot alpha:
    subplot(2,2,2)
    plotYlin(xToPloti, alphi, '.-','color',colors(i,:),...
        'MarkerSize',10)
    hold on
    xlabel(xlabelStr), ylabel('\alpha')
%     continue
    
    indsC = C2>0 & n==i;
 
    % Plot C:
    subplot(2,2,3)
    plotYlog(xToPlot(indsC), C2(indsC)*1e12, '.-','color',colors(i,:),...
        'MarkerSize',20)
    hold on
    xlabel(xlabelStr), ylabel('C^2 [(\mu\Phi_0)^2/Hz]')

    % Plot gamma:
    subplot(2,2,4)
    plot(xToPlot(indsC), gam(indsC), '.-','color',colors(i,:),...
        'MarkerSize',20)
    hold on
    xlabel(xlabelStr), ylabel('\gamma')
end

if length(b) > 1
    legend(legends,'Interpreter','none')
end

title(sprintf('f_{min} = %g, f_{max} = %g',fMin,fMax))

end

%% Average like spectra:

% plotAverage = false;
% 
% [b, m, n] = unique([[tcM.T]', [tcM.SQUID]'],'rows');
% 
% s = spectrum.empty(length(m),0);
% sf = sFit.empty(length(m),0);
% 
% if plotAverage, colors = lines(length(m)); figure, end
% Rsq = zeros(length(m),1);
% for i = 1:length(m)
%     s(i) = mean(tcM(n==i));
%     s(i).noNoise = true;
%     sf(i) = sFit(s(i));
%     
% %     sf(i).fMin = fMin;
% %     sf(i).fMax = fMax;
%     sf(i).fitLorentz = fitLorentz;
%     sf(i).enforceWN = enforceWN;    
%     
%     if plotAverage
%         plot(s(i),'Color',colors(i,:))
%         hold on
%         plot(sf(i),'Color',colors(i,:))
%     end
%     
%     % Calculate R^2:
%     temp = (sf(i).SyFit.S - sf(i).s.S).^2;
%     Rsq(i) = sum(temp(fMin <= s(i).f & s(i).f <= fMax));
% end
% % xlim([fMin fMax])
% 
% coeffAvg = reshape([sf.coeff],6,length(sf))';
% 
% figure
% colors = lines(6);
% for i=1:6
%     plot( b(b(:,2)==i,1), coeffAvg(b(:,2)==i,3), '-o', 'color', colors(i,:))
%     hold on
% end
% 
% figure
% colors = lines(6);
% for i=1:6
%     plot( b(b(:,2)==i,1), coeffAvg(b(:,2)==i,4), '-o', 'color', colors(i,:))
%     hold on
% end
% 
% return