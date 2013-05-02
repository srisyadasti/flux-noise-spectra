function dat_to_mat(varargin)

switch length(varargin)
    case 1
        assert(ischar(varargin{1}))
        filename = varargin{1};
        [dt y] = timeCapture.importTC(filename); %#ok<*NASGU,*ASGLU>
    case 3
        assert(ischar(varargin{1}))
        assert(isnumeric(varargin{2}))
        assert(isnumeric(varargin{3}))
        
        filename = varargin{1};
        dt = varargin{2}; 
        y = varargin{3}; 
    otherwise
end

% s = struct('dt',dt, 'y',y);

bitSize = min(diff(unique(y)));
y16 = int16(y/bitSize); %#ok<NASGU>

[pathstr, name, ~] = fileparts(filename);

% save(fullfile(pathstr,name), 'dt', 'y')
save(fullfile(pathstr,name), 'dt', 'y16', 'bitSize')

end