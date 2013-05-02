function measProf = measurementProfile(startTime)
%
% INPUT
%   startTime   = Start time of the time capture [yyyy MB dd] or
%                 [yyyy MB dd HH MB SS].
% OUTPUT
%   measProf    = Struct with fields corresponding to parameters of the
%                 measurement.

%% Measurement profiles:

%% NIST1_c1
measmnts{1}.runName = 'NIST1_c1';
measmnts{1}.startDate = [2010 10 1];
measmnts{1}.stopDate =  [2010 12 4];
measmnts{1}.Mi = 1e6/0.1899; % Phi0/A
measmnts{1}.Mf = 1e6/5.479; % Phi0/A
measmnts{1}.Rc = 0.4528; % ohms
measmnts{1}.dVFLLdPhiA = 1e-3 * ...
    [27.322, 51.427, 103.27, 168.14, 278.4, 467.4, 677.0, 1006.5]; %V/Phi0
measmnts{1}.MB = 1e6./[44.3, 46.6, 42.6, 43.7, 36.6, 42.2]; % Phi0/A

%% NIST1_c2
measmnts{end+1}.runName = 'NIST1_c2';
measmnts{end}.startDate = [2010 12 8];
measmnts{end}.stopDate  = [2010 12 19];
measmnts{end}.Mi = 1e6/0.1899; % Phi0/A
measmnts{end}.Mf = 1e6/5.479; % Phi0/A
measmnts{end}.Rc = 0.4528; % ohms
measmnts{end}.dVFLLdPhiA = 1e-3 * ...
    [27.322, 51.427, 103.27, 168.14, 278.4, 467.4, 677.0, 1006.5]; %V/Phi0
measmnts{end}.MB = 1e6./[44.3, 46.6, 42.6, 43.7, 36.6, 42.2]; % Phi0/A

%% UIUC1_c1
measmnts{end+1}.runName = 'UIUC1_c1';
measmnts{end}.startDate = [2011 01 2];
measmnts{end}.stopDate  = [2011 01 29];
measmnts{end}.Mi = 1e6/0.1899; % Phi0/A
measmnts{end}.Mf = 1e6/5.479; % Phi0/A
measmnts{end}.Rc = 0.4528; % ohms
measmnts{end}.dVFLLdPhiA = 1e-3 * ...
    [27.322, 51.427, 103.27, 168.14, 278.4, 467.4, 677.0, 1006.5]; %V/Phi0
measmnts{end}.MB = 1e6./[NaN 44.65 44.65 44.51 44.57 NaN]; % Phi0/A

%% NIST2_cf1
measmnts{end+1}.runName = 'NIST2_cf1'; % failed run: input coil open
measmnts{end}.startDate = [2011 2 1];
measmnts{end}.stopDate =  [2011 2 4];
measmnts{end}.Mi = 1e6/0.1899; % Phi0/A
measmnts{end}.Mf = 1e6/5.479; % Phi0/A
measmnts{end}.Rc = 0.4528; % ohms
measmnts{end}.dVFLLdPhiA = 1e-3 * ...
    [27.322, 51.427, 103.27, 168.14, 278.4, 467.4, 677.0, 1006.5]; %V/Phi0
measmnts{end}.MB = 1e6./NaN; % Phi0/A

%% Just a probe run where we measured the measuring SQUID:
measmnts{end+1}.runName = 'NIST2_cp1';
measmnts{end}.startDate = [2011 2 7];
measmnts{end}.stopDate =  [2011 2 12];
measmnts{end}.Mi = 1e6/0.1899; % Phi0/A
measmnts{end}.Mf = 1e6/5.479; % Phi0/A
measmnts{end}.Rc = 0.4528; % ohms
measmnts{end}.dVFLLdPhiA = ... %V/Phi0
    [0.0499, 0.0939, 0.1886, 0.3070, 0.5082, 0.8533, 1.2362, 1.8381];
measmnts{end}.MB = 1e6./NaN; % Phi0/A

%% NIST2_c1
measmnts{end+1}.runName = 'NIST2_c1'; % 
measmnts{end}.startDate = [2011 2 12];
measmnts{end}.stopDate =  [2011 3 20];
measmnts{end}.Mi = 1e6 / 0.1898; % Phi0/A
measmnts{end}.Mf = 1e6 / 9.982; % Phi0/A
measmnts{end}.Rc = 0.573; % ohms
measmnts{end}.dVFLLdPhiA = ... %V/Phi0
    [0.0499, 0.0939, 0.1886, 0.3070, 0.5082, 0.8533, 1.2362, 1.8381];
measmnts{end}.MB = 1e6./[118.1, 132.7, NaN, NaN, 128.3, 120]; % Phi0/A

%% A re-measurement of original NIST chip (6 different geometries):
measmnts{end+1}.runName = 'NIST1_c3'; % 
measmnts{end}.startDate = [2011 3 28];
measmnts{end}.stopDate =  [2011 4 6];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.1898; % Phi0/A
measmnts{end}.Mf = 1e6 / 9.982; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0
    [0.0499, 0.0939, 0.1886, 0.3070, 0.5082, 0.8533, 1.2362, 1.8381];
% Properties of measurement loop:
measmnts{end}.Rc = 0.4528; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[44.3, 46.6, 42.6, 43.7, 36.6, 42.2]; % Phi0/A

%% A measurement of UIUC e452:
measmnts{end+1}.runName = 'UIUCe452_c1'; % 
measmnts{end}.startDate = [2011 4 9];
measmnts{end}.stopDate =  [2011 4 16];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.1898; % Phi0/A
measmnts{end}.Mf = 1e6 / 9.982; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0
    [0.0499, 0.0939, 0.1886, 0.3070, 0.5082, 0.8533, 1.2362, 1.8381];
% Properties of measurement loop:
measmnts{end}.Rc = 0.4528; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[NaN, 44.735, 44.285, NaN, NaN, NaN]; % Phi0/A

%% A measurement of UIUC e455:
measmnts{end+1}.runName = 'UIUCe455_c1'; % 
measmnts{end}.startDate = [2011 4 19];
measmnts{end}.stopDate =  [2011 4 23];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.1898; % Phi0/A
measmnts{end}.Mf = 1e6 / 9.982; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0
    [0.0499, 0.0939, 0.1886, 0.3070, 0.5082, 0.8533, 1.2362, 1.8381];
% Properties of measurement loop:
measmnts{end}.Rc = 0.4528; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[44, 44, 44, 44, 44, 44]; % Phi0/A

%% A measurement of original NIST chip:
measmnts{end+1}.runName = 'NIST1_c4'; % 
measmnts{end}.startDate = [2011 4 26];
measmnts{end}.stopDate =  [2011 5 26];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.1898; % Phi0/A
measmnts{end}.Mf = 1e6 / 9.982; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0
    [0.0499, 0.0939, 0.1886, 0.3070, 0.5082, 0.8533, 1.2362, 1.8381];
% Properties of measurement loop:
measmnts{end}.Rc = 0.4528; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[44.3, 46.6, 42.6, 43.7, 36.6, 42.2]; % Phi0/A

%% A measurement of Jeff's and Jed's Al SQUIDs:
measmnts{end+1}.runName = 'Jeff1_c1'; % 
measmnts{end}.startDate = [2011 6 1];
measmnts{end}.stopDate =  [2011 6 20];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.1898; % Phi0/A
measmnts{end}.Mf = 1e6 / 9.982; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0
    [0.0499, 0.0939, 0.1886, 0.3070, 0.5082, 0.8533, 1.2362, 1.8381];
% Properties of measurement loop:
measmnts{end}.Rc = 0.4528; % ohms
% Properties of measurement SQUID(s):
% (SQUID 2 might be messed up, 3 definitely is)
measmnts{end}.MB = 1e3./[3.94, 3.98, NaN, 3.95, 3.97, 3.97]; % Phi0/A
measmnts{end}.MB(100) = mean(measmnts{end}.MB([1 2 4 5 6])); % Phi0/A

%% A measurement of Martin's Re SQUIDs:
measmnts{end+1}.runName = 'MartinC6_c1'; % 
measmnts{end}.startDate = [2011 6 27];
measmnts{end}.stopDate =  [2011 7 01];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.1898; % Phi0/A
measmnts{end}.Mf = 1e6 / 9.982; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0
    [0.0499, 0.0939, 0.1886, 0.3070, 0.5082, 0.8533, 1.2362, 1.8381];
% Properties of measurement loop:
measmnts{end}.Rc = 0.4528; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[NaN, NaN, NaN, NaN, NaN, 43]; % Phi0/A

%% A measurement of MIT device (DSM6-10-1-5) B3:
measmnts{end+1}.runName = 'MIT5B3_c1'; % 
measmnts{end}.startDate = [2011 8 14];
measmnts{end}.stopDate =  [2011 10 1];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0 % 20k was not measured!!!!!!!!!!!
    [0.0271, NaN, 0.0271*4, NaN, 0.2773, NaN, NaN, 1.0046];
% Properties of measurement loop:
measmnts{end}.Rc = 0.4528; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[157, 606, 2536, 11814, NaN, 11883]; % Phi0/A

%% A measurement of a UIUC device for critical current measurements:
measmnts{end+1}.runName = 'UIUCe243a_c2'; % 
measmnts{end}.startDate = [2011 10 6];
measmnts{end}.stopDate =  [2011 10 17];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0 % 20k was not measured!!!!!!!!!!!
    [0.0271, NaN, 0.0271*4, NaN, 0.2773, NaN, NaN, 1.0046];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[NaN, NaN, NaN, NaN, NaN, NaN]; % Phi0/A

%% A measurement of MIT device (DSM6-10-1-5) C3:
measmnts{end+1}.runName = 'MIT5C3_c1'; % 
measmnts{end}.startDate = [2011 10 30];
measmnts{end}.stopDate =  [2011 11 18];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0 % 20k was not measured!!!!!!!!!!!
    [0.0271, NaN, 0.0271*4, NaN, 0.2773, NaN, NaN, 1.0046];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[58.7, 217, 823.3, 3206.2, 13585, 11837]; % Phi0/A

%% A measurement of Au-capped SQUIDs made by Chris:
measmnts{end+1}.runName = 'Chris1_c1'; % 
measmnts{end}.startDate = [2011 11 30];
measmnts{end}.stopDate =  [2011 12 07];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0 % 20k was not measured!!!!!!!!!!!
    [0.0271, NaN, 0.0271*4, NaN, 0.2773, NaN, NaN, 1.0046];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1300, 1300, 1300, 1300, 1300, 1300]; % Phi0/A
measmnts{end}.MB(100) = 1e6/1300;

%% A measurement of Au-capped SQUIDs made by Chris:
% Also, Jeff did an oxygen plasma cleaning of the surface.
measmnts{end+1}.runName = 'Chris1_c2'; % 
measmnts{end}.startDate = [2011 12 09];
measmnts{end}.stopDate =  [2011 12 15];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0 % 20k was not measured!!!!!!!!!!!
    [0.0271, NaN, 0.0271*4, NaN, 0.2773, NaN, NaN, 1.0046];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1269, 1287, 1302, 1275, 1258, 1261]; % Phi0/A
measmnts{end}.MB(100) = 1e6/1300;

%% A measurement of fresh Au-capped ebeam-Nb SQUIDs w/ Al JJs made by Chris:
% Accidentally cooled in large applied field
measmnts{end+1}.runName = 'Chris2_c1'; % 
measmnts{end}.startDate = [2011 12 16];
measmnts{end}.stopDate =  [2011 12 17];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0 % 20k was not measured!!!!!!!!!!!
    [0.0271, NaN, 0.0271*4, NaN, 0.2773, NaN, NaN, 1.0046];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1370, 1370, 1370, 1370, 1370, 1370]; % Phi0/A
measmnts{end}.MB(100) = 1e6/1370;

%% A measurement of fresh Au-capped ebeam-Nb SQUIDs w/ Al JJs made by Chris:
% Warmed to >10 K for 7.5 minutes and cooled in zero applied field
measmnts{end+1}.runName = 'Chris2_c2'; % 
measmnts{end}.startDate = [2011 12 17];
measmnts{end}.stopDate =  [2011 12 20];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0 % 20k was not measured!!!!!!!!!!!
    [0.0271, NaN, 0.0271*4, NaN, 0.2773, NaN, NaN, 1.0046];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1370, 1370, 1370, 1370, 1370, 1370]; % Phi0/A
measmnts{end}.MB(100) = 1e6/1370;

%% A measurement of a second batch of fresh Au-capped ebeam-Nb SQUIDs 
% Chip Nb02 w/ Al JJs made by Chris:
measmnts{end+1}.runName = 'Chris3_c1'; % 
measmnts{end}.startDate = [2012 01 16];
measmnts{end}.stopDate =  [2012 01 29];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = ... %V/Phi0 % 20k was not measured!!!!!!!!!!!
    [0.0271, NaN, 0.0271*4, NaN, 0.2773, NaN, NaN, 1.0046];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1345, 1353, 1365, NaN, NaN, 1337]; % Phi0/A
measmnts{end}.MB(12) = mean(measmnts{end}.MB(1:2));
measmnts{end}.MB(13) = mean(measmnts{end}.MB(1:3));
measmnts{end}.MB(100) = 1e6/1350;

%% Diced chips from NIST; SQUIDs 1, 4 are SiNx, 3, 6 have oxide stripped
measmnts{end+1}.runName = 'NIST_SiNx1'; % 
measmnts{end}.startDate = [2012 04 09];
measmnts{end}.stopDate =  [2012 04 13];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
% IMPORTANT NOTE: We are now using the StarCryo electronics. The measuring
% SQUID is the same, so only dV/dPhiA will be different.
measmnts{end}.dVFLLdPhiA = ... %
    [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[169.6, NaN, 183.2, NaN, NaN, 168.3]; % Phi0/A

%% Diced chips from NIST; SQUIDs 1, 4 are SiNx, 3, 6 have oxide stripped
measmnts{end+1}.runName = 'NIST_SiNx2'; % 
measmnts{end}.startDate = [2012 04 18];
measmnts{end}.stopDate =  [2012 04 25];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
% IMPORTANT NOTE: We are now using the StarCryo electronics. The measuring
% SQUID is the same, so only dV/dPhiA will be different.
measmnts{end}.dVFLLdPhiA = ... %
    [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[129.7, NaN, 147.9, 143.4, NaN, 149.5]; % Phi0/A

%% Diced chips from NIST; SQUIDs 1, 4 are SiNx, 3, 6 have oxide stripped
measmnts{end+1}.runName = 'NIST_SiNx3'; % 
measmnts{end}.startDate = [2012 04 29];
measmnts{end}.stopDate =  [2012 05 05];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
% IMPORTANT NOTE: We are now using the StarCryo electronics. The measuring
% SQUID is the same, so only dV/dPhiA will be different.
measmnts{end}.dVFLLdPhiA = ... %
    [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[54.5, NaN, 62.9, 61.8, NaN, 69.0]; % Phi0/A

%% From UIUC; passivated with NbNx on all SQUIDs:
% Actually, we later found out that these SQUIDs have no NbNx.
measmnts{end+1}.runName = 'e523E'; % 
measmnts{end}.startDate = [2012 05 10];
measmnts{end}.stopDate =  [2012 06 03];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
% IMPORTANT NOTE: We are now using the StarCryo electronics. The measuring
% SQUID is the same, so only dV/dPhiA will be different.
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[981.1, 1004.3, 1055.3, 1011.5, 980.7, 976.0]; % Phi0/A

%% NIST3_c1: From first batch of NIST SQUIDs, design 2:
measmnts{end+1}.runName = 'NIST3_c1'; % 
measmnts{end}.startDate = [2012 07 04];
measmnts{end}.stopDate =  [2012 07 30];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[44.3, 46.4, 42.4, 43.6, 36.4]; % Phi0/A

%% e543A, hybrid NbNx SQUIDs from UIUC:
measmnts{end+1}.runName = 'e543A'; % 
measmnts{end}.startDate = [2012 08 02];
measmnts{end}.stopDate =  [2012 08 10];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[NaN NaN NaN NaN NaN NaN]; % Phi0/A

%% e543B, hybrid NbNx SQUIDs from UIUC:
measmnts{end+1}.runName = 'e543B'; % 
measmnts{end}.startDate = [2012 08 15];
measmnts{end}.stopDate =  [2012 09 03];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
% measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
measmnts{end}.Rc = 0.4; % ohms % This value is made up to match the noise!!
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1276.5 1320.3 1311.9 1326.6 1320.9 NaN]; % Phi0/A

%% e544A, hybrid NbNx with Al2O3 SQUIDs from UIUC:
measmnts{end+1}.runName = 'e544A'; % 
measmnts{end}.startDate = [2012 09 06];
measmnts{end}.stopDate =  [2012 09 16];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
% measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
measmnts{end}.Rc = 0.4; % ohms % This value is made up to match the noise!!
% Properties of measurement SQUID(s):

% SQUID 2 mutual not actually measured!!!
measmnts{end}.MB = 1e6./[1323.0 1330 1347.6 1341.6 1331.4 NaN]; % Phi0/A

%% e544C, hybrid, NbNx + SiNx-capped SQUIDs from UIUC:
measmnts{end+1}.runName = 'e544C'; % 
measmnts{end}.startDate = [2012 09 18];
measmnts{end}.stopDate =  [2012 09 30];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
% measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
measmnts{end}.Rc = 0.4; % ohms % This value is made up to match the noise!!
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1317.0 1338.0 1345.2 1340.1 1330.5 NaN]; % Phi0/A

%% P77A, hybrid, sputtered NbNx Chris:
measmnts{end+1}.runName = 'P77A'; % 
measmnts{end}.startDate = [2012 10 02];
measmnts{end}.stopDate =  [2012 10 06];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
% measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
measmnts{end}.Rc = 0.4; % ohms % This value is made up to match the noise!!
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1182.8 1204.4 1205.7 NaN NaN 1184.6]; % Phi0/A

%% P77B, hybrid, sputtered NbNx Chris:
measmnts{end+1}.runName = 'P77B'; % 
measmnts{end}.startDate = [2012 10 18];
measmnts{end}.stopDate =  [2012 10 30];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
% measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
measmnts{end}.Rc = 0.4; % ohms % This value is made up to match the noise!!
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1183.3 1204.7 1204.9 1197.0 1195.6 NaN]; % Phi0/A

%% SiNx on bottom, hybrid:
measmnts{end+1}.runName = 'SiNx_bot'; % 
measmnts{end}.startDate = [2013 01 14];
measmnts{end}.stopDate =  [2013 01 19];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
% measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
measmnts{end}.Rc = 0.4; % ohms % This value is made up to match the noise!!
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1276.2 1284.6 1284.9 1321.5 1319.4 NaN]; % Phi0/A

%% SiNx on top and bottom, hybrid:
measmnts{end+1}.runName = 'SiNx_topbot'; % 
measmnts{end}.startDate = [2013 01 20];
measmnts{end}.stopDate =  [2013 01 30];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN];
% Properties of measurement loop:
% measmnts{end}.Rc = 0.453; % ohms % Probably not exactly correct, but whatevs
measmnts{end}.Rc = 0.4; % ohms % This value is made up to match the noise!!
% Properties of measurement SQUID(s):
measmnts{end}.MB = 1e6./[1275.0 1283.1 1280.4 1265.1 1266.6 NaN]; % Phi0/A

%% epi-Al + SiNx:
measmnts{end+1}.runName = 'epiAl_SiNx'; % 
measmnts{end}.startDate = [2013 02 20];
measmnts{end}.stopDate =  [2013 03 10];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN]; % V/Phi_0 in readout
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measured SQUID(s):
measmnts{end}.MB = 1e6./[NaN NaN NaN NaN 1417.0 NaN]; % Phi0/A

%% Al + SiNx (SGS-B&D):
measmnts{end+1}.runName = 'SGS-BD'; % 
measmnts{end}.startDate = [2013 04 25];
measmnts{end}.stopDate =  [2013 04 29];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN]; % V/Phi_0 in readout
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measured SQUID(s):
measmnts{end}.MB = 1e6./[1223.7 1231.8 1228.4 NaN 1290.1 NaN]; % Phi0/A

%% Al + SiNx (SGS-A&C):
measmnts{end+1}.runName = 'SGS-AC'; % 
measmnts{end}.startDate = [2013 04 30];
measmnts{end}.stopDate =  [2013 05 07];
% Properties of measuring SQUID:
measmnts{end}.Mi = 1e6 / 0.193; % Phi0/A
measmnts{end}.Mf = 1e6 / 5.49; % Phi0/A
measmnts{end}.dVFLLdPhiA = [NaN, 0.5530, NaN, NaN]; % V/Phi_0 in readout
% Properties of measurement loop:
measmnts{end}.Rc = 0.453; % ohms
% Properties of measured SQUID(s):
measmnts{end}.MB = 1e6./[1282.8 1269.7 1269.5 NaN 1412.4 NaN]; % Phi0/A

%% Match measurement profile to given date:

whichMeas = @(S) all([datenum(startTime) - datenum(S.startDate), ...
    datenum(S.stopDate) - datenum(startTime)] > 0);

matchingMeas = cellfun(whichMeas,measmnts);

if nnz(matchingMeas) == 0
    warning('MATLAB:measurementProfile:noMatchingMeasurements',...
        sprintf(['No measurements found for the date specified:\n',...
        '%02d-%02d-%04d %02d:%02d:%02d'],...
        startTime([2 3 1 4 5 6]))) %#ok<SPWRN>
    measmnts{end+1}.runName = 'No measurements found'; %
    measmnts{end}.startDate = [0 0 0];
    measmnts{end}.stopDate =  [0 0 0];
    measmnts{end}.Mi = NaN;
    measmnts{end}.Mf = NaN;
    measmnts{end}.Rc = NaN;
    measmnts{end}.dVFLLdPhiA = NaN(8,1);
    measmnts{end}.MB = NaN;
elseif nnz(matchingMeas) > 1
    error('MATLAB:measurementProfile:multipleMatchingMeasurements',...
        'Multiple measurements found for the date specified.')
end

measProf = measmnts{cellfun(whichMeas,measmnts)};
        
end