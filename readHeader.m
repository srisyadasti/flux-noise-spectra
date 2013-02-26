function header = readHeader(varargin)

% Cell of filenames, filename, or directory?
args = {};
for i=1:nargin
    if iscell(varargin{i})
        args = [args, varargin{i}];
    else
        args{end+1} = varargin{i};
    end
end

filenames = {};
% Loop over all input args:
for argNum = 1:length(args)
    % if directory, add files to list of filenames to import:
    if isdir(args{argNum})
        r = dir(args{argNum});
        for i = 3:length(r)
            % Only read .dat filenames:
            if ~isempty(regexpi(r(i).name,'\.dat'))
                filenames{end+1} = r(i).name;
            end
        end
        % if file, add filename to list of filenames:
    elseif ~isempty(dir(args{argNum}))
        filenames{end+1} = args{argNum}; %#ok<*AGROW>
    end
end

header = {};
for fileNum = 1:length(filenames)
    % Import the first 200 lines of the file:
    % fileHeader = importdata(filenames{fileNum},'',200); % <- slower
    fid = fopen(filenames{fileNum});
    C = textscan(fid, '%s', 200, 'delimiter','\n');
    fclose(fid);
    fileHeader = C{1};
    
    nHead = length(fileHeader);
    if nHead == 0
        fprintf('File %s not readable.\n',filenames{fileNum})
        continue
    end
    
    % Determine labels and values:
    for headLine = 1:nHead
        labelAndValue = regexp(fileHeader{headLine}, ': ', 'split');
        tempHeadLabel{headLine} = labelAndValue{1};
        tempHeadValue{headLine} = [labelAndValue{2:end}];
    end
    
    % Add tempHead to header
    header{end+1}.label = tempHeadLabel;
    header{end}.value = tempHeadValue;
    
end % for fileNum

if nargin == 1 && ~iscell(varargin{1})
    if isempty(header)
        warning('MATLAB:readHeader:emptyHeader',...
            'Empty header file. Check filename.')
    else
        header = header{1};
    end
end
   
end