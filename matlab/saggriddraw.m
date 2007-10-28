function grids = saggriddraw(grids);

% SAGGRIDDRAW Draws a grid of the Scanalyze format.

% VIS
  
% version 0.3 
% Copyright (c) Neil Lawrence 2001

for i = 1:length(grids)
%  offSet = [grids(i).spotWidth/2 grids(i).spotHeight/2];
  
  firstPoint =  [grids(i).left grids(i).top];
  secondPoint =  [grids(i).left + (grids(i).columns - 1)*grids(i).colX ...
		 grids(i).top + (grids(i).columns - 1)*grids(i).colY];
  thirdPoint =  [grids(i).left + (grids(i).rows - 1)*grids(i).rowX ...
		grids(i).top + (grids(i).rows - 1)*grids(i).rowY];
  fourthPoint =  [grids(i).left + (grids(i).columns - 1)*grids(i).colX ...
		 + (grids(i).rows - 1)*grids(i).rowX ...
		 grids(i).top + (grids(i).columns - 1)*grids(i).colY ...
		 + (grids(i).rows - 1)*grids(i).rowY];
  xTopPoints = linspace(firstPoint(1, 1), ...
		     secondPoint(1, 1), ...
		     grids(i).columns)';
  yTopPoints = linspace(firstPoint(1, 2), ...
		     secondPoint(1, 2), ...
		     grids(i).columns)';
  xBottomPoints = linspace(thirdPoint(1, 1), ...
		     fourthPoint(1, 1), ...
		     grids(i).columns)';
  yBottomPoints = linspace(thirdPoint(1, 2), ...
		     fourthPoint(1, 2), ...
		     grids(i).columns)';
  xLeftPoints = linspace(firstPoint(1, 1), ...
		     thirdPoint(1, 1), ...
		     grids(i).rows)';
  yLeftPoints = linspace(firstPoint(1, 2), ...
		     thirdPoint(1, 2), ...
		     grids(i).rows)';
  yRightPoints = linspace(secondPoint(1, 2), ...
		     fourthPoint(1, 2), ...
		     grids(i).rows)';
  xRightPoints = linspace(secondPoint(1, 1), ...
		     fourthPoint(1, 1), ...
		     grids(i).rows)';
  for j = 1:grids(i).rows
    horizontalx(j, :) = [xLeftPoints(j) xRightPoints(j)];
    horizontaly(j, :) = [yLeftPoints(j) yRightPoints(j)];
  end
  for j = 1:grids(i).columns
    verticalx(j, :) = [xBottomPoints(j) xTopPoints(j)];
    verticaly(j, :) = [yBottomPoints(j) yTopPoints(j)];
  end
  try
    numLines = grids(i).columns+grids(i).rows;
    if length(grids(i).handle) ~= numLines
      delete(grids(i).handle);
      grids(i).handle = [];
      grids(i) = skewgriddraw(grids(i));
    else
      for j = 1:grids(i).rows
	set(grids(i).handle(j), 'XData', horizontalx(j, :), 'YData', horizontaly(j, :));
      end
      for j = 1:grids(i).columns
	set(grids(i).handle(j+grids(i).rows)', 'XData', verticalx(j, :), 'YData', verticaly(j, :));
      end
    end
  catch
    % grids don't have a handle - create one
    grids(i).handle = line(horizontalx', horizontaly');
    grids(i).handle = [grids(i).handle; line(verticalx', verticaly')];
    col = get(grids(i).handle(1), 'color');
    set(grids(i).handle, 'color', col);
     
  end
end



