function [tcM, tcMall] = plotSpectra(tcMall)
% Function plots a specified subset of spectra from tcMall.

% I usually change the run configuration to run this instead:
%   if exist('tcMall','var'), [tcM tcMall] = plotSpectra(tcMall); end

% Check that tcMall is specified:
narginchk(1, 1)

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
assert(length([tcM.tcFileSize]) == length(tcM));
assert(length([tcM.startTime])/6 == length(tcM));

%% Pick time captures run for tcM:

% cellStrToInd = @(cellStr,str) ...
%     cellfun(@(x) ~isempty( strfind(x,str) ), cellStr);

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

% tcM = tcM(~cellfun(@isempty,strfind({tcM.filename},'junk')));

%% Pick time captures run for tcM:

tcM = tcM([tcM.tcFileSize] > 20e6); % tc filesize greater than 50MB

% tcM = tcM([tcM.T] == 0.4);
% tcM = tcM([tcM.T] >= 1.4 & [tcM.T] <= 3);

tcM = tcM(~[tcM.fluxModOn]);

tcM = tcM([tcM.flux] ~= 0 & ~isnan([tcM.flux]) & [tcM.vout]>0 & ...
    [tcM.vin]>0);
% tcM = tcM([tcM.flux] == 0.25);
% tcM = tcM([tcM.flux] == 0);
% tcM = tcM([tcM.flux] == 0 | [tcM.SQUID] == 0);

tcM = tcM([tcM.fMax] < 400);
% tcM = tcM([tcM.fMax] < 400 | [tcM.SQUID] == 0);
% tcM = tcM([tcM.fMax] > 1000);

% tcM = tcM([tcM.SQUID] == 3 | [tcM.SQUID] == 5);
% tcM = tcM([tcM.SQUID] ~= 2 & [tcM.SQUID] ~= 100);
tcM = tcM([tcM.SQUID] == 1);
tcM = tcM([tcM.SQUID] < 10);

% tcM = tcM(abs([tcM.R] - 2.5) < 0.1);
% dates = datenum(vertcat(tcM.startTime));
% tcM = tcM(dates < datenum([2011 5 16 0 0 0]));
% tcM = tcM(abs([tcM.drift]) < 1.5e-3);
% tcM = tcM([tcM.totalTime] >= 3200*0.99); % Only hour-long captures
% tcM = tcM(abs([tcM.totalTime] - 800) < 1); % Only hour-long captures

avgOn = false;
% avgOn = true;

fitOn = false;
% fitOn = true;

fMin = 0.0;
fMax = 375;
% fMax = 1e3;
enforceWN = true;
fitLorentz = true;
labelFields = {'T','SQUID','flux','R'};

%% Condition plotting parameters:

if isempty(tcM), disp('No time captures found...'), return, end

for i = 1:length(tcM)
    if  any([tcM.flux] == 0 | [tcM.flux] == -1 | isnan([tcM.flux]))
        tcM(i).yUnit = 'Ii';
    else
        tcM(i).yUnit = 'phi';
    end
%     tcM(i).yUnit = 'Ii';
%     tcM(i).yUnit = 'phia';
%     tcM(i).yUnit = 'vfll';
    
    tcM(i).tcS.s.noNoise = true;
%     tcM(i).sf.updatedFit = false;
%     tcM(i).tcS.minAvgs = 12;
    
    tcM(i).tcS.autoStitch = true;
%     tcM(i).tcS.autoStitch = false;
%     tcM(i).tcS.avgs = 4; tcM(i).tcS.fCuts = [];
end

%% Combine spectra if averaging:
spectraProps = [[tcM.T]', [tcM.SQUID]', [tcM.flux]', [tcM.fMax]', [tcM.R]'];
spectraToPlot = spectrum.empty(0,0);

if avgOn
    [uniqueProps, nInd, mInd] = unique(spectraProps,'rows');
    for i = 1:size(uniqueProps,1)
        spectraToPlot(i) = mean(tcM(i == mInd));
    end
else % no averaging:
    for i = 1:length(tcM)
        spectraToPlot(i) = tcM(i).s;
    end
    nInd = 1:length(tcM);
end

%% Initialze arrays:

if fitOn
    fitLegends = cell(length(nInd),1);
    legendHandles = zeros(length(nInd),1);
end

dataHandles = zeros(length(nInd),1);
dataLegends = cell(length(nInd),1);
colors = lines(length(nInd));

%% Plot everything:

maxY = 0; minY = inf; 

figure
for i = 1:length(spectraToPlot)
    % Plot and store the handle to the plot:
    dataHandles(i) = plot(spectraToPlot(i),'Color',colors(i,:));
    hold on
    maxY = max([spectraToPlot(i).S(2:end); maxY]);
    minY = min([spectraToPlot(i).S(2:end); minY]);
    
    if fitOn
        sf = sFit(spectraToPlot(i));
        sf.fMin = fMin;
        sf.fMax = fMax;
        sf.fitLorentz = fitLorentz;
        sf.enforceWN = enforceWN;
        
        fitPlot = plot(sf,'Color',colors(i,:));
        fitLegends{i} = sprintf('%s', sf.legendStr);
        
        % if ~avgOn, tcM(i).sf = sf; end
        legendHandles(i) = fitPlot;
    end
end

% Matlab does a sucky job of setting y-limits. I do a better job:
ylim(10.^[floor(log10(minY)), ceil(log10(maxY))])

%% Labels:

% The title contains all the info that's common among all plots:
labelFieldUnique = false(size(labelFields));
titl = '';
for i = 1:length(labelFields)
    if length(unique([tcM.(labelFields{i})])) == 1
        labelFieldUnique(i) = true;
        titl = sprintf('%s, %s = %g',...
            titl, labelFields{i}, tcM(1).(labelFields{i}) );
    end
end
titl = titl(3:end); % remove ' , '
title(titl)

% The legend entries contain data that is time-capture-specific:
for i = 1:length(nInd)
    str = '';
    for j = find(~labelFieldUnique)
        str = sprintf('%s, %s = %g',...
            str, labelFields{j}, tcM(nInd(i)).(labelFields{j}));
            % str, labelFields{j}, tcM(i).(labelFields{j}));
    end
    str = str(3:end);
    dataLegends{i} = str;
end
dataLegends = dataLegends(1:length(nInd));

% Insert legend:
if fitOn
    if isempty(dataLegends{1})
        legend(legendHandles, fitLegends)
    else
        legend(legendHandles, strcat(dataLegends, ...
            repmat({', '},size(fitLegends)), fitLegends))
    end
else
    legend(dataHandles, dataLegends)
end

end