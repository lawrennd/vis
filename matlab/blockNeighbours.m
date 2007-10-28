function imageLikelihood = blockNeighbours(spotNo, imageLikelihood, saggrid, ovals)

% BLOCKNEIGHBOURS Block out regions in the likelihood image.
% FORMAT
% DESC blocks out regions in the likleihood image.
% ARG spotNo : spot number.
% ARG imageLikelihood : the image likelihood.
% ARG saggrid : the SAG grid.
% ARG ovals : the ovals.
% RETURN imageLikelihood : the new image likelihood.
%
% COPYRIGHT : Neil D. Lawrence, 2003
%
% SEEALSO : processImage
  
% VIS

rows = saggrid.rows;
cols = saggrid.columns;
indices = [];

% Find neighbouring spots.
remVal = rem(spotNo, saggrid.rows);
if spotNo > saggrid.rows
  % THe row above the spot
  indices = [indices spotNo - saggrid.rows];
  if remVal >1 | remVal == 0
    indices = [indices, spotNo - saggrid.rows - 1];
  end      
  if remVal ~= 0
    indices = [indices, spotNo - saggrid.rows + 1];
  end
end
% The spot to the left
if remVal > 1 | remVal == 0
  indices = [indices spotNo - 1];
end
% The spot to the right
if remVal ~= 0
  indices = [indices spotNo + 1];
end
% The row below the spot
if spotNo + saggrid.rows <= saggrid.rows*saggrid.columns
  indices = [indices spotNo + saggrid.rows];
  if remVal >1 | remVal == 0
    indices = [indices, spotNo + saggrid.rows - 1];
  end      
  if remVal ~= 0
    indices = [indices, spotNo + saggrid.rows + 1];
  end
end
if any(indices< 1) 
  warning ('Indices less than 1');
end
% These indices are those of all pixels within the initial ovals.
[iFore jFore] = ovalsubscript(ovals(indices));
gridForeIndices = sub2ind([imageLikelihood.gridSize(2) imageLikelihood.gridSize(1)], ...
			  iFore - imageLikelihood.minRow + 1, ...
			  jFore - imageLikelihood.minCol + 1); 


imageLikelihood.gridForeLl(gridForeIndices) = -328;