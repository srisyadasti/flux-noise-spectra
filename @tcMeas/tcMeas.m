classdef tcMeas < handle
   
   
   % Properties to monitor:
   properties (SetObservable, AbortSet)
      yUnit = 'Vfll'
      filename
   end
   
   % Properties that are set internally:
   properties (SetAccess = private)
      % Variables for measured SQUID:
      header
      startTime
      T           = NaN
      fMax        = NaN
      SQUID       = NaN
      R           = NaN
      Ic          = NaN
      Ib          = NaN
      dVFLLdPhiA  = NaN % dVFLL/dPhi in measuring SQUID
      
      % Variables for measurement setup:
      rfdbck      = NaN
      rfdbckInd   = NaN
      electronics = ''
      
      
      % Variables for the standard measurement:
      flux        = NaN % flux through measured SQUID
      vin         = NaN % vin measured from lock-in for dI/dPhi msrmnt
      vout        = NaN % vout measured from lock-in for dI/dPhi msrmnt
      dIdV_lockin = NaN % current into flux bias coil /
      % voltage output from lock-in
      dIidVFLL    = NaN % current in input coil / voltage in FLL
      dIidPhiB    = NaN % for measured SQUID
      dPhiBdVFLL  = NaN % Phi0 in measured SQUID / voltage in FLL
      
      % Variables for flux modulation
      fluxModOn   = false
      fMod        = NaN       % frequency of the flux modulation tone
      dIdV_lockin_Mod = NaN   % Conversion from output voltage of the
      %    modulation lock-in to a current
      fluxModRMS  = NaN       % RMS magnitude of flux modulation (A)
      Tconst      = NaN       % Time constant of filter on lock-in
      Sensitivity = NaN       % Voltage scale sensitivity on lock-in
      FullScaleVout = NaN     % Voltage output on lock-in when input is
      %    equal to the maximum.
      
      % Various other variables
      measProf    % the struct containing the measurement profile
      tcS         % the tcFFT object containing the spectrum and FFT
      % parameters
      sf          % the sFit object containing the fit of the spectrum
   end
   
   % Aliased properties:
   properties (SetAccess = private, Dependent)
      tc
      s       % aliased to tcM.tcS.s
      coeff   % aliased to tcM.sf.coeff
      f0      % aliased to tcM.sf.f0
      R2      % aliased to tcM.sf.R2
      drift   % aliased to tcM.tcS.drift
      runName % aliased to tcM.measProf.runName
      totalTime   % alieased to tcM.tc.totalTime
      yConvFactor      % = dyUnit / dVfll
      yUnitLabel
      filenameTC
   end
   
   % Properties for internal use within the class methods:
   properties (Access = private)
      updatedFit = false
   end
   
   methods
      %% Class constructor:
      function tcM = tcMeas(filename)
         
         % Adds a listener to whether the filename has changed:
         addlistener(tcM, 'filename','PostSet',@tcM.fnChangedHandler);
         
         % Ads a listener to whether the yUnit has been changed
         addlistener(tcM,'yUnit','PostSet',@tcM.UpdatedFitFalse);
         
         if nargin > 0
            % Filename was specified (remove _tc if it exists):
            tcM.filename = regexprep(filename,'_tc','');
         end
      end
      
      %% Get aliased parameters:
      
      % Fit coefficients:
      function coeff = get.coeff(tcM), coeff = tcM.sf.coeff; end
      
      % f0 is the knee where the 1/f portion intersects the white noise
      function f0 = get.f0(tcM), f0 = tcM.sf.f0; end
      
      % R^2 value of the fit:
      function R2 = get.R2(tcM), R2 = tcM.sf.R2; end
      
      % Drift of the time capture:
      function drift = get.drift(tcM), drift = tcM.tcS.drift; end
      
      % Total time of the time capture:
      function tot = get.totalTime(tcM), tot = tcM.tc.totalTime; end
      
      % runName of the time capture:
      function runName = get.runName(tcM)
         runName = tcM.measProf.runName;
      end
      
      %% Get methods:
      
      % Get the time capture object:
      function tc = get.tc(tcM)
         % Since the time capture is not stored by default (that would take
         % too much memory), create one and return it.
         tc = timeCapture(tcM.filenameTC);
      end
      
      % Get the spectrum, scaled to the correct units:
      function s = get.s(tcM)
         s = tcM.tcS.s * tcM.yConvFactor^2;
      end
      
      % Get the spectrum fit
      function sf = get.sf(tcM)
         % If the fit isn't updated, then run the fit routine:
         if ~tcM.updatedFit
            sf = sFit(tcM.s);
            tcM.sf = sf;
            tcM.updatedFit = true; % fit is now updated
         else
            sf = tcM.sf;
         end
      end
      
      % Get the time capture filename:
      function filenameTC = get.filenameTC(tcM)
         filenameTC = regexprep(tcM.filename,'\.dat','_tc.dat');
      end
      
      % Get the conversion factor:
      function yConvFactor = get.yConvFactor(tcM)
         switch upper(tcM.yUnit)
            case {'VFLL'} % voltage of FLL
               yConvFactor = 1;
            case {'PHIA'} % Phi0 in readout SQUID
               yConvFactor = tcM.dIidVFLL * tcM.measProf.Mi;
            case {'II'} % current in big loop (input coil)
               yConvFactor = tcM.dIidVFLL;
            case {'PHI'} % flux in measured SQUID
               if isnan(tcM.SQUID)
                  yConvFactor = NaN;
                  return
               end
               if ~(tcM.dPhiBdVFLL > 0 && isfinite(tcM.dPhiBdVFLL))
                  warning('tcMeas:dPhiBdVFLL_invalid',...
                     'Invalid dPhi/dVFLL')
                  disp(tcM.filename)
               end
               yConvFactor = tcM.dPhiBdVFLL;
         end
         % If the flux modulation is on, then the measured voltage is
         % actually coming from the lock-in and you need to adjust for
         % the gain:
         if tcM.fluxModOn
            yConvFactor = yConvFactor*tcM.Sensitivity / ...
               tcM.FullScaleVout;
         end
         
      end
      
      % Get the y unit label:
      function yUnitLabel = get.yUnitLabel(tcM)
         switch upper(tcM.yUnit)
            case {'VFLL'} % voltage of FLL
               yUnitLabel = 'V';
            case {'PHIA','PHI'} % flux in readout or measured SQUID
               yUnitLabel = '\Phi_0';
            case {'II'} % current in big loop (input coil)
               yUnitLabel = 'A';
         end
      end
      
      %% Set the default y-axis unit:
      function set.yUnit(tcM,yUnit)
         switch upper(yUnit)
            case {'VFLL'} % voltage output of FLL
               tcM.yUnit = 'VFLL';
            case {'PHIA'} % flux in the measuring SQUID
               tcM.yUnit = 'PhiA';
            case {'II'} % current in the input coil
               tcM.yUnit = 'Ii';
            case {'PHI'} % flux in the measured SQUID
               tcM.yUnit = 'Phi';
            otherwise
               warning('tcMeas:invalidUnit', ...
                  'Invalid unit.')
               disp('Possible units:')
               disp('Vfll = output of flux locked loop')
               disp('PhiA = flux in readout SQUID')
               disp('Ii   = current in the input coil (big loop)')
               disp('Phi  = flux in measured SQUID')
         end
      end
      
      %% Set the filename:
      function set.filename(tcM,filename)
         % Remove '_tc' if it exits:
         filename = regexprep(filename,'_tc','');
         
         % Determine if relative or absolute path:
         if all(cellfun(@isempty,regexp(filename,{':','\\'}, 'once')))
            % Relative path:
            fullFilename = [pwd, '\', filename];
         else
            % Absolute path
            fullFilename = filename;
         end
         
         tcM.filename = fullFilename;
         
         % Check if filename exists:
         if ~exist(tcM.filename,'file')
            error('tcMeas:fileDoesNotExist',...
               'File not found:\n%s', tcM.filename)
         end
         
      end
      
      %% plot functions
      
      % Plot the time capture:
      function varargout = plotTC(tcM,varargin)
         h = plot(tcM.tc, varargin{:});
         if nargout == 1, varargout{1} = h; else varargout = {}; end
      end
      
      % Plot the power spectrum:
      function varargout = plot(tcM, varargin)
         h = plot(tcM.tcS * tcM.yConvFactor^2,...
            varargin{:});
         if nargout == 1, varargout{1} = h; else varargout = {}; end
         
         ylabel(sprintf('S(f) [%s^2/Hz]',tcM.yUnitLabel))
      end
      
      % Plot the power spectrum:
      function varargout = loglog(tcM,varargin)
         h = plot(tcM, varargin{:}); % just calls overloaded plot fun.
         if nargout == 1, varargout{1} = h; else varargout = {}; end
      end
      
      % Plot the power spectrum of the compensating resistor:
      function varargout = plotRc(tcM, varargin)
         % Nyquist current noise of compensating resistor:
         predS = (5.5226e-23 * tcM.T / tcM.measProf.Rc ) * ...
            tcM.yConvFactor^2 / tcM.dIidVFLL^2;
         
         hold on
         h = plot(tcM.tcS.f([2,end]), predS * [1 1],...
            varargin{:});
         if nargout == 1, varargout{1} = h; else varargout = {}; end
      end
      
      % Plot the fft of the drift of the time capture:
      function varargout = plotDrift(tcM, varargin)
         h = loglog(tcM.tcS.s.f([2,end]), tcM.yConvFactor^2 * ...
            tcM.tcS.SDrift(tcM.tcS.s.f([2,end])), ...
            varargin{:});
         if nargout == 1, varargout{1} = h; else varargout = {}; end
      end
      
      %% UpdatedFitFalse
      function UpdatedFitFalse(tcM, varargin)
         % The only thing this function does is set updatedFit to false.
         % This is because the listeners need to call a function, they
         % can't just execute some inline code.
         tcM.updatedFit = false;
      end
      
      %% Overloaded functions:
      
      % Add tcMeas, tcFFT, or spectrum objects together. Note that this is
      % only really meaningful if the measurements are just repeated
      % measurements of the same thing. What's returned is not a tcMeas
      % object, but just the added spectrum:
      function s3 = plus(varargin)
         % Create an empty spectrum:
         s12 = spectrum.empty(2,0);
         for i = 1:2
            % Determine which class type the input variables are
            switch class(varargin{i})
               case 'spectrum'
                  s12(i) = varargin{i};
               case {'tcFFT','tcMeas'}
                  s12(i) = varargin{i}.s;
               otherwise % class type not recognized
            end
         end
         
         s3 = s12(1) + s12(2);
      end
      
      % Multiply tcM by a scalar x, which we interpret as multiplying the
      % spectrum by a scalar:
      function s = mtimes(tcM, x)
         s = x * tcM.s; % mtimes is already overloaded for spectrum
      end
      
      % Divide spectrum by a scalar x:
      function s = mrdivide(tcM, x)
         s = (1/x) * tcM.s; % mtimes is already overloaded for spectrum
      end
      
      % Average input measurements. Uses the overloaded plus function,
      % which automatically returns a spectrum.
      function s = mean(varargin)
         if length(varargin{1}) > 1
            spectra = num2cell(varargin{1});
         else
            spectra = varargin;
         end
         
         s = spectrum;
         for i = 1:length(spectra)
            s = s + spectra{i};
         end
      end
      
   end
   
   methods (Access = private)
      
      %% Handler for a change in the filename:
      
      % This function is called the first time the object is created
      % (filename changes from nothing to something) or anytime the
      % filename is subsequently changed.
      function fnChangedHandler(tcM,varargin)
         % Create the tcFFT object associated with this tcMeas object:
         tcM.tcS = tcFFT(tcM.filenameTC);
         
         % Add listener to whether the FFT needs to be computed:
         addlistener(tcM.tcS,'FFT_Needs_Update',@tcM.UpdatedFitFalse);
         % The fit is not yet updated:
         tcM.updatedFit = false;
         
         % ----- Get the measurement profile info -----
         
         % Read the header from the header file:
         tcM.header = readHeader(tcM.filename);
         
         % Get the start time:
         tcM.startTime  = datevec(tcM.getValue('Start time'), ...
            'mm/dd/yyyy HH:MM:SS PM');
         
         % Import the measurement profile:
         tcM.measProf = measurementProfile(tcM.startTime);
         
         % ----- Get the readout SQUID info -----
         
         % Determine the electronics:
         if isempty(getValue(tcM,'Electronics')) || ...
               strcmpi(getValue(tcM,'Electronics'),'Mueck')
            tcM.electronics = 'Mueck';
         elseif strcmpi(getValue(tcM,'Electronics'),'StarCryo')
            tcM.electronics = 'StarCryo';
         else
            tcM.electronics = 'unknown';
         end
         
         % Get the feedback resistor:
         rfdbckstr = getValue(tcM,'Feedback resistor');
         rfdbckIn = tcMeas.parseValuePlusUnits(rfdbckstr);
         rfdbckIn = rfdbckIn{1}; % drop the units
         if rfdbckIn < 10
            tcM.rfdbckInd = rfdbckIn;
            switch upper(tcM.electronics)
               case 'MUECK'
                  rfdbckStandard = [5 10 20 30 50 85 125 185]; % kOhm
               case 'STARCRYO'
                  rfdbckStandard = [1000 100 10 1]; % kOhm
               otherwise
                  rfdbckStandard(tcM.rfdbckInd+1) = NaN;
            end
            tcM.rfdbck = rfdbckStandard(tcM.rfdbckInd+1);
         else
            tcM.rfdbckInd = -1;
            tcM.rfdbck = rfdbckIn;
         end
         
         % Get the dV_FLL/dPhi (V/Phi0):
         if tcM.rfdbckInd ~= -1
            tcM.dVFLLdPhiA = tcM.measProf.dVFLLdPhiA(tcM.rfdbckInd+1);
         elseif tcM.rfdbck == 19e3
            tcM.dVFLLdPhiA = 107.98e-3;
         end
         
         % Get the dI(big loop)/dV_FLL (A/V):
         tcM.dIidVFLL = 1 ./ (tcM.dVFLLdPhiA * tcM.measProf.Mi);
         
         % Is this a flux modulation measurement?
         if isempty(getValue(tcM,'FM'))
            tcM.fluxModOn = false;
         else
            switch upper(getValue(tcM,'FM'))
               case {'ON','TRUE'}, tcM.fluxModOn = true;
               otherwise, tcM.fluxModOn = false;
            end
         end
         
         % Get the temperature:
         Tind = ~cellfun(@isempty, ...
            strfind(upper(tcM.header.label),'T') ) ...
            & (cellfun(@length,tcM.header.label) == 1);
         if nnz(Tind) == 1
            Tstr = tcM.header.value{Tind};
            TvalPlusUnit = tcMeas.parseValuePlusUnits(Tstr);
            tcM.T = TvalPlusUnit{1};
         end
         
         % Get the maximum frequency:
         tcM.fMax = str2double(getValue(tcM,'Frequency end'));
                  
         % ----- Variables about the measured SQUID -----
         
         % Get the SQUID number:
         tcM.SQUID = str2double(getValue(tcM,'SQUID'));
         
         % Get the current in Rcomp:
         Rind = ~cellfun(@isempty, ...
            strfind(upper(tcM.header.label),'R') ) ...
            & (cellfun(@length,tcM.header.label) == 1);
         if nnz(Rind) == 1
            Rvalue = tcM.header.value{Rind};
            tcM.R = str2double(strtok(Rvalue,'uA'));
            if tcM.R < 0, tcM.R = NaN; end
         end
         
         % Get the critical current:
         tcM.Ic = str2double(strtok(getValue(tcM,'ic'),'uA'));
         if tcM.Ic < 0, tcM.Ic = NaN; end
         
         % Get the bias current:
         tcM.Ib = str2double(strtok(getValue(tcM,'ib'),'uA'));
         if tcM.Ib < 0, tcM.Ic = NaN; end
         
         % Get the SQUID flux:
         tcM.flux = str2double(getValue(tcM,'Flux'));
         if tcM.SQUID == 0, tcM.flux = NaN; end % no flux if SQUID 0
         
         % Get the voltage in:
         str = getValue(tcM,'vin');
         valPlusUnit = tcMeas.parseValuePlusUnits(str);
         tcM.vin = valPlusUnit{1};
         
         % Get the voltage out:
         str = getValue(tcM,'vout');
         valPlusUnit = tcMeas.parseValuePlusUnits(str);
         tcM.vout = valPlusUnit{1};
         
         % Get the lock-in conversion factor (A/V):
         str = getValue(tcM,'dIdV_lockin');
         if isempty(str)
            tcM.dIdV_lockin = 10.3e-9;
         else
            valPlusUnit = tcMeas.parseValuePlusUnits(str);
            tcM.dIdV_lockin = valPlusUnit{1};
         end
         
         % ----- Variables depend on whether flux modulation is on -----
         
         if tcM.fluxModOn == false
            % Parameters to convert V_FLL to flux in measured SQUID:
            if tcM.SQUID ~= 0
               PhiIntoMeasured = tcM.vin * tcM.dIdV_lockin * ...
                  tcM.measProf.MB(tcM.SQUID);
               if tcM.rfdbckInd ~= -1
                  if strcmpi(tcM.electronics,'Mueck')
                     % Lock-in measurement taken with 185k feedback:
                     ScaledVOut = tcM.vout * ...
                        tcM.dVFLLdPhiA / ...
                        tcM.measProf.dVFLLdPhiA(8);
                  else
                     ScaledVOut = tcM.vout;
                  end
               else
                  % Lock-in measurement taken with same feedback
                  % resistor as time capture:
                  ScaledVOut = tcM.vout;
               end
               tcM.dPhiBdVFLL = PhiIntoMeasured / ScaledVOut;
               
               tcM.dIidPhiB = tcM.dIidVFLL / tcM.dPhiBdVFLL;
            else
               tcM.dIidPhiB = NaN;
               tcM.dPhiBdVFLL = NaN;
            end
            
         else % tcM.fluxModOn == true:
            
            % Get the flux modulation magnitude (RMS A):
            str = getValue(tcM,'fMod');
            if isempty(str)
               tcM.fMod = NaN;
            else
               valPlusUnits = tcM.parseValuePlusUnits(str);
               tcM.fMod = valPlusUnits{1};
            end
            
            % Get the lock-in conversion factor (A/V):
            str = getValue(tcM,'dIdV_lockin_Mod');
            if isempty(str)
               tcM.dIdV_lockin_Mod = 10.3e-9;
            else
               valPlusUnit = tcMeas.parseValuePlusUnits(str);
               tcM.dIdV_lockin_Mod = valPlusUnit{1};
            end
            
            % Get the flux modulation magnitude (RMS A):
            str = getValue(tcM,'ModRMS');
            if isempty(str)
               tcM.fluxModRMS = NaN;
            else
               valPlusUnits = tcM.parseValuePlusUnits(str);
               if strcmpi(valPlusUnits{2},'A')
                  % Modulation is specified as a current:
                  tcM.fluxModRMS = valPlusUnits{1};
               elseif strcmpi(valPlusUnits{2},'V')
                  % Modulation is specified as a voltage:
                  tcM.fluxModRMS = valPlusUnits{1} * ...
                     tcM.dIdV_lockin_Mod;
               end
            end
            
            % Get the lock-in sensitivity (V)
            % (Divide by either 10V or 2.5V to get the gain):
            str = getValue(tcM,'Sensitivity');
            if isempty(str)
               tcM.Sensitivity = NaN;
            else
               valPlusUnits = tcM.parseValuePlusUnits(str);
               tcM.Sensitivity = valPlusUnits{1};
            end
            
            % Get the time constant (s):
            str = getValue(tcM,'FullScaleVout');
            if isempty(str)
               tcM.FullScaleVout = NaN;
            else
               valPlusUnits = tcM.parseValuePlusUnits(str);
               tcM.FullScaleVout = valPlusUnits{1};
            end
            
            % Get the time constant (s):
            str = getValue(tcM,'Tconst');
            if isempty(str)
               tcM.Tconst = NaN;
            else
               valPlusUnits = tcM.parseValuePlusUnits(str);
               tcM.Tconst = valPlusUnits{1};
            end
            
            tcM.dPhiBdVFLL = ...
               (tcM.vin * tcM.dIdV_lockin * ... % Test current in
               tcM.measProf.MB(tcM.SQUID)) / ... % SQUID mutual
               (tcM.vout * ... % voltage output
               tcM.Sensitivity / tcM.FullScaleVout); % Gain of lockin
            tcM.dIidPhiB = tcM.dIidVFLL / tcM.dPhiBdVFLL;
            
         end % end if tcM.fluxModOn
         
      end
      
      %% Look up the value corresponding to 'label':
      function value = getValue(tcM,label)
         value = tcM.header.value(strcmpi(tcM.header.label, label));
         if isempty(value)
            value = '';
         else
            value = value{1};
         end
      end
   end
   
   methods (Static)
      
      %% Parse the value plus units:
      
      % Function interprets a string such as '4 uA' as a value '4e-6' and a
      % unit A (amps). It's designed to handle strings such as '.4uA', too.
      function valuePlusUnit = parseValuePlusUnits(str)
         % If string is empty, there's no work to do:
         if isempty(str)
            valuePlusUnit = {NaN, []};
            return;
         end
         
         str = regexprep(str,' ',''); % remove spaces
         % Add 0 in front of leading '.'
         %    (The string '.4' needs a zero in front of the period, but the
         %    string '10.4' obviously does not.)
         str = regexprep(str,'(?<!\d)\.','0.'); 
         [valueStr unit] = regexp(str,'-?\d+\.?(\d+)?','match','split');
         if isempty(valueStr)
            value = NaN;
            unit = unit{1};
         else
            value = str2double(valueStr);
            assert(length(unit) == 2);
            unit = unit{2};
         end
         
         % Interpret SI prefixes. (case sensitive)
         SIind = regexp(unit,'([fpnumkMgG])(?=(ohm|A|V|s|K))');
         if ~isempty(SIind)
            switch unit(SIind)
               case 'f', value = value * 1e-15;
               case 'p', value = value * 1e-12;
               case 'n', value = value * 1e-9;
               case 'u', value = value * 1e-6;
               case 'm', value = value * 1e-3;
               case 'k', value = value * 1e3;
               case 'M', value = value * 1e6;
               case {'g','G'}, value = value * 1e9;
            end
            unit = unit(SIind+1:end);
         elseif isempty(regexp('ohm','(ohm|A|V|s|K)', 'once'))
            warning('tcMeas:UnitNotRecognized', ...
               'Unit not recognized: %s',unit)
         end
         
         valuePlusUnit = {value, unit};
      end
      
   end
   
   methods
      % Second spectrum function:
      tcM = secondSpectrum(tcM,varargin)
   end
   
end

