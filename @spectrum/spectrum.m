classdef spectrum < handle
   
   properties (Dependent)
      f % Frequency array
      S % Spectral density array
   end
   
   properties
      % Remove points in spectrum with very high noise? e.g. 60 Hz
      noNoise = false
   end
   
   properties (SetAccess = private)
      noiseInds % Boolean array, true if point is noisy and to be removed
   end
   
   properties (SetObservable, AbortSet)
      fPrivate        % All frequency points (noisy ones not removed)
      SPrivate        % All spectral points (noisy ones not removed)
      SSPrivate = {}  % Un-averaged spectral densities
   end
   
   methods
      %% Constructor:
      function s = spectrum(varargin)
         
         % When spectrum is changed, find the noise indices:
         addlistener(s, 'SPrivate','PostSet',@s.findNoiseInds);
         
         if nargin >= 2
            s.fPrivate = varargin{1};
            s.SPrivate = varargin{2};
            
            if nargin == 3
               s.SSPrivate = varargin{3};
            end
         end
         
      end
      
      %% get functions:
      function f = get.f(s)
         if s.noNoise
            f = s.fPrivate(~s.noiseInds);
         else
            f = s.fPrivate;
         end
      end
      
      function S = get.S(s)
         if s.noNoise
            S = s.SPrivate(~s.noiseInds);
         else
            S = s.SPrivate;
         end
      end
      
      %% Plot:
      function varargout = plot(s, varargin)
         h = loglog(s.f, s.S, varargin{:});
         if nargout == 1
            varargout{1} = h;
         end
         
         if isempty(get(get(gca,'xlabel'),'string'))
            xlabel('Frequency [Hz]')
         end
         if isempty(get(get(gca,'ylabel'),'string'))
            ylabel('S(f) [x^2/Hz]')
         end
      end
      
      %% Find noise indices:
      function findNoiseInds(s, varargin)
         % Determine which points exceed noise criterium and are 'noisy'
         
         Sy = s.SPrivate;
         noiseStd = zeros(size(Sy));
         
         for i=11:length(Sy)
            Sinds = Sy((i-10):(i-1));
            noiseStd(i) = abs(Sy(i) - mean(Sinds)) / std(Sinds);
         end
         
         s.noiseInds = noiseStd>5;
      end
      
      %% Overloaded functions:
      function s3 = plus(s1,s2)
         % Function combines two spectra.
         % At frequencies of overlap, the spectra are averaged.
         
         % If both arguments aren't of the spectrum class (the first can
         % be assumed to be a spectrum object or this overloaded
         % wouldn't have been called) then switch the order so that the
         % overloaded function from the non-spectrum class is called
         % instead:
         if ~strcmp(class(s2), 'spectrum')
            s3 = s2 + s1;
            return
         end
         
         % Find unique frequencies:
         fUnique = unique( [s1.fPrivate; s2.fPrivate] );
         
         % Determine where each spectra will add to new spectrum:
         [~, s1Inds, ~] = intersect(fUnique, s1.fPrivate);
         [~, s2Inds, ~] = intersect(fUnique, s2.fPrivate);
         
         % Populate the new spectrum:
         S = zeros(size(fUnique));
         S(s1Inds) = s1.SPrivate;
         if ~isempty(s2Inds)
            S(s2Inds) = S(s2Inds) + s2.SPrivate;
         end
         
         % Double the data at frequencies where only one spectrum has
         % contributed (if there is any overlap of the spectra):
         c = intersect(s1Inds, s2Inds);
         S(c) = S(c)/2;
         
         % Return the new spectrum object:
         s3 = spectrum(fUnique, S);
         s3.noNoise = and(s1.noNoise, s2.noNoise);
      end
      
      function s3 = mrdivide(s1,b)
         % Function divides a spectrum object by a scalar.
         s3 = spectrum(s1.fPrivate, s1.SPrivate/b);
         s3.noNoise = s1.noNoise;
      end
      
      function s3 = mtimes(varargin)
         % Function multiplies a double and spectrum object.
         S = cell(2,1);
         s3 = spectrum();
         for i = 1:2
            switch class(varargin{i})
               case 'double'
                  S{i} = varargin{i};
               case 'spectrum'
                  S{i} = varargin{i}.SPrivate;
                  s3.fPrivate = varargin{i}.fPrivate;
                  s3.noNoise = varargin{i}.noNoise;
               otherwise
            end
         end
         
         s3.SPrivate = S{1} .* S{2};
      end
      
      function s3 = mean(varargin)
         % Function will calculate the mean of the input spectra.
         if length(varargin{1}) > 1
            spectra = varargin{1};
         else
            spectra = [varargin{:}];
         end
         
         s3 = spectrum;
         for i = 1:length(spectra)
            s3 = s3 + spectra(i);
         end
      end
      
   end
   
end

