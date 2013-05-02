function fileDtbs = spectraFilesDatabase(runName)
% Function creates a list of folders that contain all the relevant time
% captures corresponding to 'runName'. In addition, folders to exclude from
% the main data (for instance, time captures taking for troubleshooting or
% testing) can be specified.
%
% INPUT:
%   runName     Name of the run or device for which to generate a list of
%               folders to import.
% OUTPUT:
%   fileDtbs    A struct with elements 'toAdd' and 'toSub', where each is a
%               cell string with the names of folders to add or subtract.


dataFold = getenv('SpectraDataFolder');
if isempty(dataFold)
   % Environment variable not set, need to set it:
   dataFold = input('Input spectra data folder:\n','s');
   setenv('SpectraDataFolder', dataFold);
end

toAdd = {};
toSub = {}; %#ok<*AGROW>

switch upper(runName)
   case {'UIUC1_C1'}
      toAdd{end+1} = fullfile(dataFold,'\UIUC1_c1');
      toSub{end+1} = 'BlackBoxShortedOpenLoop';
      toSub{end+1} = 'UpToMueckBox';
      toSub{end+1} = 'ShortedSignalAnalyzer';
   case {'UIUC452_C1','UIUCE452_C1'}
      toAdd{end+1} = fullfile(dataFold,'UIUCe452_c1');
   case {'UIUC455_C1','UIUCE455_C1'}
      toAdd{end+1} = fullfile(dataFold,'UIUCe455_c1');
   case 'NIST1_C1'
      toAdd{end+1} = fullfile(dataFold,'NIST1_c1');
      toSub{end+1} = '2010-11-30 Spectral data\SQUID2_025f_0.dat';
      % Pulses:
      toSub{end+1} = '2010-11-11 Spectral data\SQUID2_025f_1.dat';
      toSub{end+1} = '2010-11-11 Spectral data\SQUID4_025f_0.dat';
      toSub{end+1} = '2010-11-11 Spectral data\SQUID4_025f_1.dat';
      toSub{end+1} = '2010-11-11 Spectral data\SQUID4_025f_5uA_1.dat';
      toSub{end+1} = '2010-11-11 Spectral data\SQUID5_025f_1.dat';
      toSub{end+1} = '2010-11-11 Spectral data\SQUID5_025f_2.dat';
      toSub{end+1} = '2010-11-11 Spectral data\SQUID5_025f_3.dat';
      % High frequency picks up:
      %         toSub{end+1} = '2010-11-01 Spectral data\SQUID6_0f_1.dat';
      %         toSub{end+1} = '2010-11-01 Spectral data\SQUID5_0f_0.dat';
   case 'NIST1_C4'
      toAdd{end+1} = fullfile(dataFold,'NIST1_c4');
      toSub{end+1} = '2011-04-27 Spectral data 200mK\SQUID6_025f_6.dat';
      toSub{end+1} = '2011-04-28 Spectral data 200mK\SQUID2_025f_2.dat';
      toSub{end+1} = '2011-04-28 Spectral data 200mK\SQUID2_025f_7.dat';
      toSub{end+1} = '2011-04-28 Spectral data 200mK\SQUID2_025f_6.dat';
      toSub{end+1} = '2011-04-28 Spectral data 200mK\SQUID6_025f_5.dat';
      toSub{end+1} = '2011-04-28 Spectral data 200mK\SQUID6_025f_4.dat';
      toSub{end+1} = '2011-04-29 Spectral data 400mK\SQUID3_025f_1.dat';
      toSub{end+1} = '2011-05-12 Spectral data 1500mK\SQUID1_025f_1.dat';
      % Super noisy at low frequency:
      toSub{end+1} = '2011-05-06 Spectral data 2000mK\SQUID1_025f_1.dat';
      % Modulation:
      toSub{end+1} = '2011-05-24 Spectral data 4000mK\SQUID2_025f_1.dat';
   case 'NIST2_C1'
      toAdd{end+1} = fullfile(dataFold,'NIST2_c1');
   case {'JEFF1_C1'}
      toAdd{end+1} = fullfile(dataFold,'Jeff1_c1');
      toSub{end+1} = '2011-06-07 Flux bias test';
      toSub{end+1} = '2011-06-04 Spectral data 75mK';
      toSub{end+1} = '2011-06-02 Spectral data 50mK';
   case {'MARTINC6_C1'}
      toAdd{end+1} = fullfile(dataFold,'Martin1_c1');
   case {'MIT5B3_C1'}
      toAdd{end+1} = fullfile(dataFold,'MIT5B3_c1');
   case {'UIUCE243A_C2'}
      toAdd{end+1} = fullfile(dataFold,'UIUCe243a_c2');
   case {'MIT5C3_C1'}
      toAdd{end+1} = fullfile(dataFold,'MIT5C3_c1');
      toSub{end+1} = '2011-10-31 Spectral data 100 mK';
      % Was using different flux bias box:
      toSub{end+1} = '2011-11-03 Spectral data 400 mK\SQUID5_025f_1_tc';
      toSub{end+1} = 'New flux bias box';
      toSub{end+1} = 'Tmod';
      toSub{end+1} = 'Shane';
   case {'CHRIS1_C1'}
      toAdd{end+1} = fullfile(dataFold,'Chris1_c1');
      toSub{end+1} = '2011-11-30 Spectral data 100 mK\SQUID4_025f_1';
   case {'CHRIS1_C2'}
      toAdd{end+1} = fullfile(dataFold,'Chris1_c2');
   case {'CHRIS2_C1'}
      toAdd{end+1} = fullfile(dataFold,'Chris2_c1');
   case {'CHRIS2_C2'}
      toAdd{end+1} = fullfile(dataFold,'Chris2_c2');
      toSub{end+1} = 'mod';
   case {'CHRIS3_C1'}
      toAdd{end+1} = fullfile(dataFold,'Chris3_c1');
      toSub{end+1} = 'mod';
   case {'NIST_SINX1'}
      toAdd{end+1} = fullfile(dataFold,'NIST_SiNx1');
   case {'NIST_SINX2'}
      toAdd{end+1} = fullfile(dataFold,'NIST_SiNx2');
      toSub{end+1} = '2012-04-19 100mK\SQUID1_025f_3';
   case {'NIST_SINX3'}
      toAdd{end+1} = fullfile(dataFold,'NIST_SiNx3');
      toSub{end+1} = 'test';
   case {'E523E'}
      toAdd{end+1} = fullfile(dataFold,'e523e');
   case {'NIST3_C1'}
      toAdd{end+1} = fullfile(dataFold,'NIST3_c1');
      toSub{end+1} = '2012-07-07 200mK\SQUID3_025f_1';
   case {'E543A'}
      toAdd{end+1} = fullfile(dataFold,'e543A');
   case {'E543B'}
      toAdd{end+1} = fullfile(dataFold,'e543B');
   case {'E544A'}
      toAdd{end+1} = fullfile(dataFold,'e544A');
   case {'E544C'}
      toAdd{end+1} = fullfile(dataFold,'e544C');
   case {'P77A'}
      toAdd{end+1} = fullfile(dataFold,'P77A');
   case {'P77B'}
      toAdd{end+1} = fullfile(dataFold,'P77B');
   case {'SINX_BOT'}
      toAdd{end+1} = fullfile(dataFold,'SiNx_bot');
   case {'SINX_TOPBOT'}
      toAdd{end+1} = fullfile(dataFold,'SiNx_topbot');
   case {'EPIAL_SINX'}
      toAdd{end+1} = fullfile(dataFold,'epiAl_SiNx');
   case {'SGS-BD'}
      toAdd{end+1} = fullfile(dataFold,'SGS-BD');
   case {'SGS-AC'}
      toAdd{end+1} = fullfile(dataFold,'SGS-AC');
   otherwise
      disp('Unrecognized run name. Be sure to add the run to spectraFilesDatabase.')
      error('Unrecognized run name.')
end

toSub{end+1} = 'troubleshooting';
toSub{end+1} = 'test';

% Add _tc to files ending in .dat:
for i=1:length(toSub)
   toSub{end+1} = regexprep(toSub{i},'(?<!_tc)\.dat','_tc.dat');
end
toSub = unique(toSub);

fileDtbs.toAdd = toAdd;
fileDtbs.toSub = unique(toSub);

end