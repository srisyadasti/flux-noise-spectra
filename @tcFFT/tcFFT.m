classdef tcFFT < handle
   % Class definition of a stitched FFT. 
    
    properties (SetAccess = private, GetObservable)
        s         % A spectrum object
        drift     % Scalar value of drift
        SDrift    % Function handle SDrift(f) is the spectral density of 
                  % the drift
    end
    
    properties (SetAccess = private, Dependent)
        f % Frequency array, aliased to s
        S % Spectral density array, aliased to s
    end
    
    properties (SetObservable, AbortSet)
        filename     % Filename of the time capture
        tMin = 0     % Start time of good data, default = 0 (s)
        tMax = inf   % Stop time of good data, default = inf (s)
        
        autoStitch = true % Autostitch FFT?
        minAvgs = 12 % Minimum number of averages for lowest frequency FFT
        sFactor = 2  % Stitches FFTs every 2^sFactor in frequency
        
        % Default set of averages for each stitch region (if auto = off)
        avgs = [12 50 200 800 3200]
        % Default set of stitch frequencies (if auto = off)
        fCuts = [0.5/16 0.125 0.5 8]
    end
    
    properties (Dependent = true)
        tc  % timeCapture object of filename
    end
    
    properties %(Access = private)
        updated = false % Is the FFT updated?
    end
    
    events
       % Data or parameter change: FFT needs to be updated
        FFT_Needs_Update
        % Dummy function to set tcS.updated = true
        FFT_Updated
    end
    
    %% Methods:
    methods
        %% Class constructor:
        function tcS = tcFFT(filename)
            
            % Properties that require updated FFT:
            addlistener(tcS, 's',     'PreGet',@tcS.updateFFT);
            addlistener(tcS, 'drift', 'PreGet',@tcS.updateFFT);
            addlistener(tcS, 'SDrift','PreGet',@tcS.updateFFT);
            
            % Properties that, if changed, invalidate FFT:
            addlistener(tcS, 'filename','PostSet',@tcS.updatedFalse);
            addlistener(tcS, 'tMin',    'PostSet',@tcS.updatedFalse);
            addlistener(tcS, 'tMax',    'PostSet',@tcS.updatedFalse);
            
            addlistener(tcS, 'autoStitch','PostSet',@tcS.updatedFalse);
            addlistener(tcS, 'minAvgs',   'PostSet',@tcS.updatedFalse);
            addlistener(tcS, 'sFactor',   'PostSet',@tcS.updatedFalse);
            
            addlistener(tcS, 'avgs', 'PostSet',@tcS.updatedFalse);
            addlistener(tcS, 'fCuts','PostSet',@tcS.updatedFalse);
            
            if nargin > 0
                tcS.filename = filename;
            end
        end
        
        %% Aliased f and S:
        function f = get.f(tcS)
            f = tcS.s.f;
        end
        
        function S = get.S(tcS)
            S = tcS.s.S;
        end
        
        function set.f(~,~)
            error('tcFFT:cannot_set_dependent_variable',...
                'You cannot set f.')
        end
        function set.S(~,~)
            error('tcFFT:cannot_set_dependent_variable',...
                'You cannot set S.')
        end
        
        %% Update FFT functions:
        
        % Something changed, set tcS.updated to false:
        function updatedFalse(tcS, varargin)
            tcS.updated = false;
            notify(tcS,'FFT_Needs_Update')
        end
        
        % Something is requesting a parameter that needs an updated FFT:
        function updateFFT(tcS, varargin)
            if ~tcS.updated
                tcS.fftTC(tcS);
                tcS.updated = true;
                notify(tcS,'FFT_Updated')
            end
        end
        
        %% Set the filename:
        function set.filename(tcS,filename)
            
             % Check that file is a time capture:
            if isempty(regexpi(filename,'_tc','once'))
                warning('MATLAB:timeCapture:fileNotTimeCapture',...
                    'File may not be a time capture.')
            end
            
            % Relative or absolute path:
            if all(cellfun(@isempty,regexp(filename,{':','\\'}, 'once')))
                % Relative path:
                fullFilename = [pwd, '\', filename];
            else
                % Absolute path
                fullFilename = filename;
            end
            
            tcS.filename = fullFilename;
        end        
        
        %% Plotting functions:
        function varargout = loglog(tcS,varargin)
            h = plot(tcS.s, varargin{:});
            if nargout == 1
                varargout{1} = h;
            else varargout = {};
            end
        end
        
        function varargout = plot(tcS,varargin)
            h = plot(tcS.s, varargin{:});
            if nargout == 1
                varargout{1} = h;
            else varargout = {};
            end
            xlabel('Frequency [Hz]')
            ylabel('S_v(f) [V^2/Hz]')
        end
        
        % Plot the theoretical spectrum of the drift:
        function plotDrift(tcS,varargin)
            loglog(tcS.s.f([2,end]), tcS.SDrift(tcS.s.f([2,end])), ...
                varargin{:})
        end
        
        %% Misc.:
        
        % get timeCapture object:
        function tc = get.tc(tcS)
            tc = timeCapture(tcS.filename);
        end
        
        %% Overloaded functions:
        function s3 = plus(varargin)
            s12 = spectrum.empty(2,0);
            for i = 1:2
                switch class(varargin{i})
                    case 'spectrum'
                        s12(i) = varargin{i};
                    case 'tcFFT'
                        s12(i) = varargin{i}.s;
                    otherwise
                end
            end
            
            s3 = s12(1) + s12(2);
        end
        
        function s = mtimes(tcS, x)
            s = x * tcS.s;
        end
        
        function s = mean(varargin)
            % Function will calculate the mean of the input spectra.
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
    
    methods (Static)
        % FFT function:
        s = fftTC(tcS)
    end
    
end

