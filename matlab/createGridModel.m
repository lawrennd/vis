function [imageLikelihood, ovals, firstPoint, secondPoint] = createGridModel(saggrids, modelType, ...
						  gridNo, maxWidth, ...
						  maxHeight, redChannel, ...
						  greenChannel, display);

% CREATEGRIDMODEL Obtain foreground and background likelihoods for pixels in the grid.
% FORMAT
% DESC obtains the foreground and background likelihoods for pixels in the
% provided grid.
% RETURN imageLikelihood : the likelihoods of each pixel in the image.
% RETURN ovals : the ovals which were used for separating foreground and
% background in the image.
% RETURN firstPoint : top right point of the rectangle for the
% background.
% RETURN secondPoint : bottom left point of the rectangle for the background.
% ARG sagGrids : the SAG grids to be used.
% ARG modelType : the type of model to be used for foreground and
% background, either 'hist' for histogram or 'lognormal' for lognormal.
% ARG gridNo : the grid number to process from the saggrids.
% ARG addWidth : the extra width around the grid to process.
% ARG addHeight : the extra height around the grid to process.
% ARG redChannel : the values of the red channel.
% ARG greenChannel : the values from the green channel.
% ARG display : should be set to 0 for no display, 1 for text display and 2 for
% image display. The latter setting is useful for ensuring you have the
% parameters of the variational importance sampler set reasonably.
%
% COPYRIGHT : Neil D. Lawrence, 2002, 2003, 2007
%
% SEEALSO : processImage, modelDataHist, modelDataLnNorm

% VIS

ovals = saggrid2oval(saggrids(gridNo));

% Calculate a top right and bottom left point of a rectangle 
% that includes the parallelogram representing the grid

rows = saggrids(gridNo).rows;
cols = saggrids(gridNo).columns;

firstPoint(1) = min([ovals(1).centre(1) ...
		    ovals(rows*cols - cols + 1).centre(1)]);
firstPoint(2) = min([ovals(1).centre(2) ...
		    ovals(cols).centre(2)]);

secondPoint(1) = max([ovals(end).centre(1) ...
		    ovals(cols).centre(1)]);
secondPoint(2) = max([ovals(end).centre(2) ...
		    ovals(rows*cols - cols + 1).centre(2)]);

if display > 1
  figure(1)
  axis([firstPoint(1)-maxWidth secondPoint(1)+maxWidth ...
	firstPoint(2)-maxHeight secondPoint(2)+maxHeight]);
end

% These indices are those of all pixels within the initial ovals.
[iFore jFore] = ovalsubscript(ovals);

% These indices are those of all pixels within the grid.
jPoints = round(firstPoint(1)-maxWidth):round(secondPoint(1)+maxWidth);
iPoints = round(firstPoint(2)-maxHeight):round(secondPoint(2)+maxHeight);
[iFull,  jFull] = meshgrid(iPoints, jPoints);
iFull = iFull(:);
jFull = jFull(:);
fullIndex = sub2ind(size(redChannel), iFull, jFull);

% Compute the corners of the grid
topLeft = [min(jFull) min(iFull)];
bottomRight = [max(jFull) max(iFull)];
gridSize = bottomRight - topLeft + 1;

% Get the indices of the grid which are foreground
gridForeIndices = sub2ind(gridSize, ...
			  jFore - topLeft(1) + 1, ...
			  iFore - topLeft(2) + 1); 


% Extract the red data
redX = redChannel(fullIndex);

% Extract the green data
greenX = greenChannel(fullIndex);

% Label according to foreground/background
t = zeros(size(redX));
t(gridForeIndices) = 1;

% Index the foreground and background
backIndex = find(t==0);
foreIndex = find(t==1);
imageLikelihood.minCol = topLeft(1);
imageLikelihood.minRow = topLeft(2);
imageLikelihood.gridSize = gridSize;  
switch modelType

  case 'hist'
   % Background model
   imageLikelihood.gridBackLl = modelDataHist(redX, greenX, backIndex, ...
			      gridSize, display);
   % Foreground model
   imageLikelihood.gridForeLl = modelDataHist(redX, greenX, foreIndex, ...
			      gridSize, display);
 case 'lognormal'
   % Background model
   imageLikelihood.gridBackLl = modelDataLnNorm(redX, greenX, backIndex, ...
			      gridSize, display);
   % Foreground model
   imageLikelihood.gridForeLl = modelDataLnNorm(redX, greenX, foreIndex, ...
			      gridSize, display);
  
 otherwise
  error('Unknown model type requested.')
end
