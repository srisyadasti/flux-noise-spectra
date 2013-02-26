function inds = cellStrToInd(cellStr,str)
    inds = cellfun(@(x) ~isempty( strfind(x,str) ), cellStr);
end