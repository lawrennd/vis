function [infoStore, saggridsOut] = processImage(fileStem, display, gridRange)

% PROCESSIMAGE processes a cDNA microarray image.
% FORMAT
% DESC This function processes a cDNA microarray image, returning a structure containing various expectations of interest.
% ARG fileStem : The array images are expected to be stored in two channels,
% red is fileStemA.tif and green fileStemB.tif. The function looks for a
% scanalyze grid file called fileStem.sag to initialise the grids.
% ARG display : should be set to 0 for no display, 1 for text display and 2 for
% image display. The latter setting is useful for ensuring you have the
% parameters of the variational importance sampler set reasonably.
% ARG gridRange : an optional vector specifying which grids from the array
% you wish to process.
% RETURN infoStore : some information from the processing.
% RETURN saggridsOut : the output processing grids.
%
% COPYRIGHT : Neil D. Lawrence, 2002, 2003, 2007
%
% SEEALSO : imread, sagread, createGridModel, ovalVISampler

% VIS

if nargin < 2
  % default display value
  display = 1;
end

I_max = 65535;  % The maximum pixel value.
DATASETS = getenv('DATASETS');

redChannel = imread([fileStem 'A.tif']);
greenChannel = imread([fileStem 'B.tif']);
blueChannel = repmat(uint16(0), size(redChannel));
currentImage = cat(3, redChannel, greenChannel, blueChannel);

if display > 1  % display > 1 means plot what you are doing
  % This is useful for determining whether parameters are set O.K.  
  figure(1)
  image(currentImage);
  axis equal
  set(gcf, 'doublebuffer', 'on')
end
  
numSamps = 100;

centreSD = 1; % The standard deviation of centres prior
centrePrior.beta = 1/(centreSD*centreSD);    % The precision of the centres prior
centrePrior.S_inv = eye(2); % The covariance of the centre's wishart distribution
centrePrior.nu = 8;         % The degrees of freedom of the centre's wishart distribution

correlatedRadiusSD = 2; % The standard deviation of the radiicentres prior
anticorrelatedRadiusSD = 0.5;
eigVectors = [sqrt(2)/2 sqrt(2)/2; sqrt(2)/2 -sqrt(2)/2];
eigVals = 1./[correlatedRadiusSD^2 anticorrelatedRadiusSD^2];
radiusPrior.precision = eigVectors*diag(eigVals)*eigVectors';      % The precision of the radii prior 
radiusPrior.S_inv = eye(2); % The inverse covariance of the radii's wishart distribution
radiusPrior.nu  = 8;        % The degrees of freedom of the centre's wishart distribution


maxIters = 20;              % Maximum number of iterations for each spot

% Read the initial grid placement from a scanalyze grid file
saggrids = sagread([fileStem '.sag']);

if nargin < 3
  % default grid range (all of them)
  gridRange = 1:length(saggrids);
elseif max(gridRange) > length(saggrids)
  error('Element of input grid range is too large')
end

counter = 0;
for i = gridRange
  currentGrid = saggrids(i);
  counter = counter + 1;

  rows = currentGrid.rows;
  cols = currentGrid.columns;

  maxWidth = currentGrid.colX;
  maxHeight= currentGrid.rowY;
  
  infoStore(counter).gridNo = i;
  
  % Text display even if display is 0
  fprintf('Grid %d\n', i)
  fprintf('Computing likelihoods\n', i)  
  [imageLikelihood, origOvals] = createGridModel(saggrids, 'hist', i, maxWidth, ...
					     maxHeight, redChannel, ...
					     greenChannel, display);
  if display > 1
    figure(1)
    % If we are visualising what is going on --- plot it
    %/~
    %    origOvals = ovaldraw(origOvals);
    %~/
    clf
    set([origOvals.handle], 'linestyle', ':', 'color', [1 0 1])
    drawnow
    
    % Update the title so we know where we are
    txtTitle = title([fileStem ' Grid ' num2str(i) ' of ' num2str(length(saggrids))]);
    set(txtTitle, 'fontsize', 18);
    set(txtTitle, 'fontname', 'verdana');
    iRange = imageLikelihood.minRow:imageLikelihood.minRow+imageLikelihood.gridSize(2)-1; 
    jRange = imageLikelihood.minCol:imageLikelihood.minCol+imageLikelihood.gridSize(1)-1;
    imagesc(jRange, iRange, imageLikelihood.gridBackLl./ ...
	    (imageLikelihood.gridForeLl + imageLikelihood.gridBackLl)); 
    colormap gray
    %/~
    %origOvals = ovaldraw(origOvals);
    %set([origOvals.handle], 'linestyle', '-', 'color', [0 0 0])
    %~/
  end
  fprintf('Likelihoods done\n', i)  

  %/~
  % Offset saggrid as test for grid refining.
  %currentGrid.left = currentGrid.left - 3;
  %currentGrid.top = currentGrid.top - 3;
  %~/
  if display > 1 
    figure(1)
    currentGrid = saggriddraw(currentGrid);
    set([currentGrid.handle], 'linestyle', '-', 'color', [0 0 1])
  end
  %/~
  % Refine the grid with a variational importance sampler.
  %  [newGrid, origOvals] = saggridVISampler(currentGrid, imageLikelihood, display, origOvals);
  %~/
  newGrid = currentGrid;
  if display > 1 
    figure(1)
    saggridsOut(i) = saggriddraw(newGrid);
    set([saggridsOut(i).handle], 'linestyle', '-', 'color', [1 0 0])
  else
    saggridsOut(i) = newGrid;
  end

  for spotNo = 1:length(origOvals)
    sagGridRow = 1+floor(spotNo/cols);
    remVal = rem(spotNo,cols);
    if remVal
      sagGridCol = remVal;
    else
      sagGridCol = cols;
    end
    modImageLikelihood = blockNeighbours(spotNo, imageLikelihood, ...
                                         saggridsOut(i), origOvals);
    %/~
    %    if display > 1
    %      figure(2), clf
    %      imagesc(jRange, iRange, modImageLikelihood.gridForeLl./ ...
    %	      (modImageLikelihood.gridForeLl + modImageLikelihood.gridBackLl)); 
    %      colormap gray
    %    end
    %~/
    [ovals, importanceWeights] = ovalVISampler(origOvals(spotNo), ...
					       modImageLikelihood, ...
					       display);
%					       display, currentGrid);
    
    % Create a saggrid to save the results
    centres = reshape([ovals.centre], 2, length(ovals))';
    radiiX = [ovals.xradius]';
    radiiY = [ovals.yradius]';

    % Set the centres to the expectation of the centres
    centreY = importanceWeights'*centres(:, 2); 
    centreX = importanceWeights'*centres(:, 1);

    % Set the radii to the expectation of the radii
    radiusY = importanceWeights'*radiiY;  
    radiusX = importanceWeights'*radiiX;

    % Create ovals at the mean values
    meanOvals(spotNo) = ovalcreate([centreX centreY], radiusX, radiusY);
    saggridsOut(i).widthOverride(sagGridRow, sagGridCol) = meanOvals(spotNo).xradius*2;
    saggridsOut(i).heightOverride(sagGridRow, sagGridCol) = meanOvals(spotNo).yradius*2;
    offSets = meanOvals(spotNo).centre - origOvals(spotNo).centre;
    trueOffset = (offSets*inv([currentGrid.rowX currentGrid.colX; currentGrid.rowY currentGrid.colY]))*100;
    saggridsOut(i).rowOffset(sagGridRow, sagGridCol) = trueOffset(1);
    saggridsOut(i).columnOffset(sagGridRow, sagGridCol) = trueOffset(2);
    
    if length(ovals) == 1
      % No spot has been found --- flag the position with a 2
      saggridsOut(i).flag(sagGridRow, sagGridCol) = 2;
      infoStore(counter).log2Var(spotNo) = NaN;
      infoStore(counter).log2Exp(spotNo) = NaN;
      infoStore(counter).redVals(spotNo) = NaN;
      infoStore(counter).greenVals(spotNo) = NaN;
      infoStore(counter).redVar(spotNo) = NaN;
      infoStore(counter).greenVar(spotNo) = NaN;
      infoStore(counter).effSamps(spotNo) = NaN;
      infoStore(counter).flag(spotNo) = 2;
    end

    if length(ovals)>1
      % A spot has been found --- use importance weights to compute some values
      [ratios, log2Ratios, ...
       redValues, greenValues, ...
       redBackground, greenBackground] = ...
	  extractRatios(ovals, currentImage);
      
      % values are set to -9e99 if there are no pixels within the circle --- here we remove these entries
      index = find(ratios==-9e99);  
      importanceWeights(index) = [];
      importanceWeights = importanceWeights/sum(importanceWeights);
      ratios(index) = [];
      log2Ratios(index) = [];
      redValues(index) = [];
      greenValues(index) = [];
      redBackground(index) = [];
      greenBackground(index) = [];
      
      % For the remaining examples compute some expectations of interest
      ratios_exp =  importanceWeights'*ratios;
      log2Ratios_exp =  importanceWeights'*log2Ratios;
      ratiosSquared_exp = importanceWeights'*(ratios.*ratios);
      log2RatiosSquared_exp = importanceWeights'*(log2Ratios.*log2Ratios);
      ratio_var = ratiosSquared_exp - ratios_exp.*ratios_exp;
      log2Ratio_var = log2RatiosSquared_exp - log2Ratios_exp.*log2Ratios_exp;
      redVal = importanceWeights'*redValues;
      greenVal = importanceWeights'*greenValues;
      redVar = importanceWeights'*(redValues.*redValues) - redVal*redVal;
      greenVar = importanceWeights'*(greenValues.*greenValues) - greenVal*greenVal;
      
      if display
	fprintf('%d Log ratio %f, Standard Deviation: %f\n', spotNo, log2Ratios_exp, sqrt(log2Ratio_var));
	fprintf('%d Red %f, Green %f\n', spotNo, redVal, greenVal);
      end
      
      % Store the results in the structure infoStore
      infoStore(counter).log2Var(spotNo) = log2Ratio_var;
      infoStore(counter).log2Exp(spotNo) = log2Ratios_exp;
      infoStore(counter).redVals(spotNo) = redVal;
      infoStore(counter).greenVals(spotNo) = greenVal;
      infoStore(counter).redVar(spotNo) = redVar;
      infoStore(counter).greenVar(spotNo) = greenVar;
      infoStore(counter).effSamps(spotNo) = (1/sum(importanceWeights.*importanceWeights));
      if infoStore(counter).effSamps(spotNo) < length(importanceWeights)/10
	% If the number of effective samples was very low, flag with a 3
	infoStore(counter).flag(spotNo) = 3;
	saggridsOut(i).flag(sagGridRow, sagGridCol) = 3;
      else
	infoStore(counter).flag(spotNo) = 0;
      end
    end
  end
end

% Save the grid based on the samples
sagwrite([fileStem '_sample.sag'], saggridsOut);

% write a text file which can be loaded, for example, into excel
ratiocsvwrite([fileStem '_data.csv'], infoStore);
















