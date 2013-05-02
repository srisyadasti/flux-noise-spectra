classdef timeCapture < handle
   % Class definition of a time capture
   
   %% properties
   properties
      filename % Filename of time capture
   end
   
   properties (SetAccess = private)
      dt        % Time between samples in time series (s)
      y         % y value of time series (assumed to be V)
      totalTime % Total time of time series
      tcFileSize % size of time capture (*_tc.dat) file in bytes
      drift     % Coefficient of linear regression of time series (V/hr)
   end
   
   properties (Dependent = true)
      t
   end
   
   properties (Access = private)
      updated = false       % Is time series data updated?
      updatedDrift = false  % Is calculated drift updated?
   end
   
   %% events
   events
      fileChanged % The filename has been changed, so things need updating
   end
   
   %% methods
   methods
      %% Class constructor:
      function tc = timeCapture(filename)
         % Constructor creates object from filename
         
         % Listen to whether file has changed:
         addlistener(tc,'fileChanged',@tc.fileChangedHandler);
         
         if nargin > 0
            tc.filename = filename;
            
            if exist(tc.filename,'file')
               % Determine file size:
               r = dir(tc.filename);
               tc.tcFileSize = r.bytes;
            end
         end
      end % end timeCapture
      
      %% plot (overloaded):
      function varargout = plot(tc,varargin)
         if tc.totalTime > 600
            t = (tc.dt/60) * (0:length(tc.y) - 1);
            tUnit = 'min';
         else
            t = tc.dt * (0:length(tc.y) - 1);
            tUnit = 's';
         end
         
         h = plot(t, tc.y*1000);
         xlabel(sprintf('Time elapsed (%s)',tUnit))
         ylabel('FLL output (mV)');
         
         % Optional plotting of moving average:
         if nargin > 1 && strcmpi(varargin{1},'ma')
            % Determine if movingAvgN is specified:
            if nargin > 2 && isnumeric(varargin{2})
               movingAvgN = varargin{2};
            else
               movingAvgN = 1023;
            end
            
            hold on
            % Calculate and plot the moving average:
            b = ones(1,movingAvgN)/movingAvgN;
            tDataMA = filter(b,1,tc.y);
            h(2) = plot(t(movingAvgN:end), ...
               tDataMA(movingAvgN:end)*1e3,'r');
            hold off
         elseif nargin > 1 && strcmpi(varargin{1},'ideal')
            % Choose the range of the bandpass filter:
            if nargin == 2 
               bPass = [0,0.5];
            elseif nargin > 2
               bPass = varargin{2};
            end
            
            % Create and plot the filter
            ts = timeseries(tc.y);
            ts1 = idealfilter(ts, bPass*tc.dt, 'pass');
            hold on
            plot(tc.t/60, (ts1.Data + mean(tc.y))*1e3,'r','linewidth',2)
         end
         
         % Return handles if requested:
         if nargout == 1
            varargout{1} = h;
         else varargout = {};
         end
      end % end plot
      
      %% get time capture data functions:
      
      % Front end variables:
      function dt = get.dt(tc)
         updateTC(tc)
         dt = tc.dt;
      end
      
      function t = get.t(tc)
         t = tc.dt * (0:length(tc.y) - 1);
      end
      
      function y = get.y(tc)
         updateTC(tc)
         y = tc.y;
      end
      
      function totalTime = get.totalTime(tc)
         updateTC(tc)
         totalTime = tc.totalTime;
      end
      
      function drift = get.drift(tc)
         if ~tc.updatedDrift
            % Calculate drift:
            t = tc.dt * (0: length(tc.y) - 1)';
            driftFit = [t, ones(size(t))] \ tc.y; % linear regression
            tc.drift = driftFit(1) * 3600; % V/hr drift
            tc.updatedDrift = true;
         end
         drift = tc.drift;
         
         %             fprintf('The drift was %.3f mV/hr.\n', drift*1000);
      end
      
      % Updating function
      function updateTC(tc)
         if ~tc.updated
            % Import the time capture:
            %                 tc.importTC;
            [tc.dt, tc.y] = timeCapture.importTC(tc.filename);
            % Set the updated flag to true:
            tc.updated = true;
            
            % Total time of time capture:
            tc.totalTime = tc.dt * (length(tc.y) - 1);
         end
      end
      
      function set.filename(tc,filename)
         % Check that file is a time capture:
         if isempty(regexpi(filename,'_tc.dat','once'))
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
         
         oldFilename = tc.filename;
         tc.filename = fullFilename;
         
         % Check if filename exists:
         if ~exist(tc.filename,'file') && ...
               ~exist(strrep(tc.filename,'_tc.dat','_tc.mat'),'file')
            error('tcMeasurement:fileDoesNotExist',...
               'File not found:\n%s', tc.filename)
         end
         
         % if filename is changed, trigger an event:
         if ~strcmpi(tc.filename, oldFilename) && ~isempty(oldFilename)
            notify(tc,'fileChanged')
         end
         
      end
      
   end % end methods
   
   %% Import time capture file:
   methods (Static)
      function [dt y] = importTC(filename)
         
         % Split the file path into component parts:
         [pathstr, name, ext] = fileparts(filename);
         
         % If the _tc file has extension .dat and does NOT have a .mat
         % file that has already been generated, then import the .dat
         % file (which is a slow process) and then generate a .mat file
         % for faster importing the next time.
         if strcmpi(ext,'.dat') && ...
               ~exist(fullfile(pathstr, [name,'.mat']),'file')
            
            % Open file:
            fID = fopen(filename);
            
            % Search for dt value:
            lCount = 1;
            while true
               fline = fgetl(fID);
               hInfo = regexp(fline, ':', 'split');
               if strcmp(hInfo{1},'dt')
                  dt = str2double(hInfo{2});
                  break
               end
               lCount = lCount + 1;
               if lCount > 100
                  error('dt information not found')
               end
            end
            
            importedData = textscan(fID,'%f');
            fclose(fID);
            
            y = importedData{1};
            
            %{
                This method is slower than the textscan function:
                % Import the y data:
                importedData = importdata(filename,'',lCount);
                assert(isfield(importedData,'data'),...
                    'importTC:importData_failure',...
                    'Failure importing time capture data.')
                
                % Save parameters:
                y = importedData.data;
            %}
            
            % Create a .mat file for faster importing:
            dat_to_mat(filename, dt, y);
         else
            % Load the .mat file:
            s = load(fullfile(pathstr, [name,'.mat']));
            assert(isstruct(s));
            
            % Since ADC in signal analyzer is not greater than 16 bits,
            % it doesn't make sense to store more bits than that.
            % Therefore, the format is to convert and store the data as
            % 16-bit integers, and then convert back to double when the
            % data is loaded.
            assert(all(isfield(s,{'dt','y16','bitSize'})), ...
               'Unrecognized .mat file.')
            dt = s.dt;
            y = double(s.y16)*s.bitSize;
            clear s
         end
      end
   end
   
   %% methods (Access = private)
   methods (Access = private)
      
      % fileChangedHandler:
      function fileChangedHandler(tc,varargin)
         % File has been changed, set updated to false:
         tc.updated = false;
         tc.updatedDrift = false;
         tc.dt = [];
         tc.y = [];
         tc.drift = [];
         
         % Determine file size:
         r = dir(tc.filename);
         tc.tcFileSize = r.bytes;
      end
   end
   
end