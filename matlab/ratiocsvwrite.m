function ratiocsvwrite(fileName, infoStore)

% RATIOCSVWRITE Takes a structure giving results and writes to a csv file.

% VIS
  
% version 0.1 
% Copyright (c) Neil Lawrence 2002

data = [];
for i = 1:length(infoStore)
  numSpots = length(infoStore(i).log2Exp(:));
  data = [data; repmat(infoStore(i).gridNo, numSpots, 1) (1:numSpots)' ...
	  infoStore(i).log2Exp(:) sqrt(infoStore(i).log2Var(:)) ...
	  infoStore(i).redVals(:) sqrt(infoStore(i).redVar(:)) ...
	  infoStore(i).greenVals(:) sqrt(infoStore(i).greenVar(:)) ...
	  infoStore(i).effSamps(:) infoStore(i).flag(:)];
end
dlmwrite(fileName, data, ',');
