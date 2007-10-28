function points = saggridpoints(saggrids)


% SAGGRIDPOINTS Extracts the centres of the ovals from scanalyze grids.
% FORMAT
% DESC extracts the centres of the ovals from scanalyze grids.
% ARG saggrids : the grids from which points are to be extracted.
% RETURN points : the centres of the ovals into 2xN array, where N is the total
% number of ovals.
%
% COPYRIGHT : Neil D. Lawrence, 2002
%
% version 0.1 
% Copyright (c) Neil Lawrence 2002

% VIS
  
numPoints = 0;
for i = 1:length(saggrids)
  numPoints = numPoints + saggrids(i).columns*saggrids(i).rows;
end

points = zeros(numPoints, 2);

for gridNo = 1:length(saggrids)
  numRows = saggrids(gridNo).rows;
  numColumns = saggrids(gridNo).columns;
  counter = 0;
  offSet = 0;
  if isfield(saggrids(i), 'rowOffset') & isfield(saggrids(i), ...
						 'columnOffset')
    offSet = 1;
  end
  for i = 1:numRows
    for j = 1:numColumns
      counter = counter + 1;
      if offSet
	rows = (i-1) + saggrids(gridNo).rowOffset(i, j)/100;
	columns = (j-1) + saggrids(gridNo).columnOffset(i, j)/100;
      else
	rows = (i - 1);
	columns = (j - 1);
      end
      points(counter, 1) = saggrids(gridNo).left ...
	  + rows*saggrids(gridNo).rowX ...
	  + columns*saggrids(gridNo).colX;
      points(counter, 2) = saggrids(gridNo).top ...
	  + rows*saggrids(gridNo).rowY ...
	  + columns*saggrids(gridNo).colY;
    end
  end
end


