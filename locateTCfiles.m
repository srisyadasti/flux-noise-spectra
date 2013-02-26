function filenames = locateTCfiles(baseFolder)

% Function recursively searches baseFolder and all subfolders for _tc
% files and returns them as a cell string.

if ~isdir(baseFolder) && ~isempty(strfind(baseFolder,'_tc')) && ...
        ~isempty(strfind(baseFolder,'.dat'))
    filenames = baseFolder;
else
    
    filenames = {};
    listing = dir(baseFolder);
    
    for i = 3:length(listing)
        if listing(i).isdir
            filenames = [filenames, ...
                locateTCfiles(fullfile(baseFolder,listing(i).name))]; ...
                %#ok<AGROW>
        else
            if ~isempty(strfind(listing(i).name, '_tc')) && ...
                    ~isempty(strfind(listing(i).name, '.dat')) && ...
                    ~isempty(strfind({listing.name}, ...
                    strrep(listing(i).name,'_tc','')))
                filenames = [filenames, ...
                    fullfile(baseFolder, listing(i).name)]; %#ok<AGROW>
            end
        end
    end
end

end