function tcMall = spectraFiles(varargin)


if nargin == 0
    error('Input required (either tcMall or runName).')
end

% Initialize the tcMall array (input or create empty):
tcMind = cellfun(@(x) isa(x,'tcMeas'), varargin);
if nnz(tcMind) == 0
    tcMall = tcMeas.empty;
else
    tcMall = vertcat(varargin{tcMind});
end

% Determine which run names to import/refresh:
if nnz(cellfun(@ischar, varargin)) == 0
    runNames = unique({tcMall.runName});
else
    runNames = unique([varargin(cellfun(@ischar, varargin)), ...
        {tcMall.runName}]);
end

% fileDtbs = struct('toAdd',{},'toSub',{});
fileDtbs.toAdd = {};
fileDtbs.toSub = {};
for i = 1:length(runNames)
    fileDtbsi = spectraFilesDatabase(runNames{i});
    fileDtbs.toAdd = [fileDtbs.toAdd, fileDtbsi.toAdd];
    fileDtbs.toSub = [fileDtbs.toSub, fileDtbsi.toSub];
end
fileDtbs.toAdd = unique(fileDtbs.toAdd);
fileDtbs.toSub = unique(fileDtbs.toSub);

%% Add time capture files from specified files and directories to list:
filenames = {};
for i = 1:length(fileDtbs.toAdd)
    filenames = [filenames, locateTCfiles(fileDtbs.toAdd{i})]; %#ok<AGROW>
end

%% Determine which files to import:

% Discard redundant filenames (there shouldn't be any):
filenames = unique(filenames);

% Discard filenames that match those already in tcMall:
[~, m, ~] = unique([filenames, {tcMall.filename}, {tcMall.filenameTC}],...
    'last');
filenames = filenames(m(m <= length(filenames)));

% Remove junk captures:
for i = 1:length(fileDtbs.toSub)
    filenames(cellfun(@(x) ...
        ~isempty( strfind(x,fileDtbs.toSub{i}) ), ...
        filenames)) = [];
end

%% Import the list of time capture files into tcMeas object array:

for i = 1:length(filenames)
    if exist(filenames{i},'file')
        tcMall(end+1) = tcMeas(filenames{i}); %#ok<AGROW>
        
        % Check that the file size is not too small (which indicates
        % that it wasn't saved correctly):
        if getfield(dir(tcMall(end).filenameTC),'bytes') < 1024
            warning('spectraFiles:invalidTCfile',...
                'Time capture file not saved correctly:\n%s',...
                tcMall(end).filenameTC)
            tcMall = tcMall(1:end-1);
        end
        
    else
        warning('spectraFiles:fileNotFound',...
            'Missing file will not be imported:\n%s',filenames{i})
    end
end

%% Sort the tcMeas array

% Sort by tcMeas array:
if isempty(tcMall)
    error('spectraFiles:empty_tcMall','tcMall is empty');
end
[~, ind] = sortrows([[tcMall.T]; [tcMall.SQUID]; [tcMall.flux]; ...
    [tcMall.R]; [tcMall.fMax]]',[1 2 3 4 5]);
tcMall = tcMall(ind);

tcMall = reshape(tcMall,length(tcMall),1);

%% Condition the time captures:

% conditionTCs(tcMall);

end