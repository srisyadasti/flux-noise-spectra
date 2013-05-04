classdef sFit < handle
    
    properties
        s = spectrum();
        updatedFit = false
    end
    
    properties (SetObservable, AbortSet)
        fMin = 0
        fMax = Inf
        fitLog = true
        enforceWN = false
        fitLorentz = false
    end
    
    properties (GetObservable)
        coeff
        coeffErr
        SyFitFun = @(f) NaN
    end
    
    properties (Dependent, GetObservable)
        SyFit
        legendStr
        
        f0 = NaN % Frequency at which 1/f noise = white noise
        R2 = NaN % R^2 of fit
    end
    
    methods
        %% Class constructor:
        function sf = sFit(s)
            
            % Spectrum object is specified:
            if nargin == 1
                assert(isa(s,'spectrum'));
                % Set the spectrum in sf to the input spectrum:
                sf.s = s;
            end
            
            % Properties that, if changed, invalidate fit:
            addlistener(sf,'fMin',      'PostSet',@sf.updateFitFalse);
            addlistener(sf,'fMax',      'PostSet',@sf.updateFitFalse);
            addlistener(sf,'fitLog',    'PostSet',@sf.updateFitFalse);
            addlistener(sf,'enforceWN', 'PostSet',@sf.updateFitFalse);
            addlistener(sf,'fitLorentz','PostSet',@sf.updateFitFalse);            
            
            % Properties that require updated fit:
            addlistener(sf,'coeff',    'PreGet',@sf.updateFit);
            addlistener(sf,'coeffErr', 'PreGet',@sf.updateFit);
            addlistener(sf,'SyFitFun', 'PreGet',@sf.updateFit);
            addlistener(sf,'legendStr','PreGet',@sf.updateFit);
        end
        
        %% Fit update functions:
        
        % Something was changed that invalidates the fit:
        function updateFitFalse(sf, varargin)
            sf.updatedFit = false;
        end
        
        % Something is requesting a parameter that needs an updated fit:
        function updateFit(sf, varargin)
            if ~sf.updatedFit
                fitS(sf); % fit the spectrum in sf (i.e. sf.s)
                sf.updatedFit = true;
            end
        end
        
        %% Get functions:
        
        % Get the f0 frequency:
        function f0 = get.f0(sf)
            f0 = exp((log(sf.coeff(3))-log(sf.coeff(1))) ./ ...
                (sf.coeff(4)-sf.coeff(2)));
        end
        
        % Get the R^2 value:
        function R2 = get.R2(sf)
            % Remove dc point:
            f = sf.s.f(2:end);
            S = sf.s.S(2:end);
            
            for i = 1:2
                % Compute the log frequency spacing and use that to weight the
                % residuals:
                df = diff(log(f));
                df(end+1) = df(end);
                df = df/sum(df);
                
                % Compute the residuals
                r = log(S) - log(sf.SyFitFun(f));
                % Sum of the squares of the residuals, weighted by f-spacing:
                SSresid = sum(df .* r.^2);
                % A weighted sum of the squared differences from the mean:
                SStotal = sum((log(S)-mean(log(S))).^2.*df);
                % The R^2 value:
                R2(3-i) = 1 - SSresid/SStotal;
                
                % Look only at frequency range of interest:
                S = S( f>=sf.fMin & f<=sf.fMax);
                f = f( f>=sf.fMin & f<=sf.fMax);
            end
        end
        
        %% Plot functions:
        function varargout = plot(sf,varargin)
            h = plot(sf.SyFit, varargin{:});
            if nargout == 1
                varargout{1} = h;
            else varargout = {};
            end
            
            % Add xlabel if there is none:
            if isempty(get(get(gca,'xlabel'),'string'))
                xlabel('Frequency [Hz]')
            end
            % Add ylabel if there is none:
            if isempty(get(get(gca,'ylabel'),'string'))
                ylabel('S(f) [x^2/Hz]')
            end
        end
        
        %% Fits:
        
        function SyFit = get.SyFit(sf)
            SyFit = spectrum(sf.s.f, sf.SyFitFun(sf.s.f));
        end
        
        %% Legend string:
        function legendStr = get.legendStr(sf)
            if sf.enforceWN
                wnTerm = sprintf('%.3g',sf.coeff(1));
            else
                wnTerm = sprintf('%.3g/f^{%.2f}',sf.coeff(1:2));
            end
            
            fnTerm = sprintf('%.3g/f^{%.2f}',sf.coeff(3:4));
            
            if sf.fitLorentz
                lorTerm = sprintf(' + %.3g L(%.3g)',sf.coeff(5:6));
            else
                lorTerm = '';
            end
            
            legendStr = sprintf('%s + %s%s',wnTerm, fnTerm, lorTerm);
        end
        
    end
    
end