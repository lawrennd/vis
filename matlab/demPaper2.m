% DEMPAPER2 This script recreates a Bioinformatics paper experiment.

% VIS

% This script does the consistency comparisions.
% Load the grid from researcher 2
tempSagGrids = sagread('./data/R1SS1.sag');

% Remove all their adjustments
for i = 1:length(tempSagGrids)
  tempSagGrids(i).widthOverride = zeros(size(tempSagGrids(i).widthOverride));
  tempSagGrids(i).heightOverride = zeros(size(tempSagGrids(i).heightOverride));
  tempSagGrids(i).rowOffset = zeros(size(tempSagGrids(i).rowOffset));
  tempSagGrids(i).columnOffset = zeros(size(tempSagGrids(i).columnOffset));
end

% Write the result to SS1.sag for processing
sagwrite('./data/SS1.sag', tempSagGrids);

% Process the data given this grid
answer = processImage('./data/SS1', 0);

% Save the results in a csv file
ratiocsvwrite('demoPaper2.csv', answer);

% Load manually placed flags showing where dust-spots are
sagFlag = sagread('./data/SS1flag.sag');

% Load data extracted from spot
spotLog2Ratio = spotlog2('ss1_spot.dat');

% Load manually extracted data
manLog2Ratio = scanalyzelog2('R2SS1.dat');

% Number of spots in each grid
numPerGrid = 256;

counter = 0;
for gridNo = 1:length(answer)
  % storePoints for later analysis
  for i = 1:2:length(answer(gridNo).log2Exp)
    manFlag = sagFlag(gridNo).flag(:);
    
    if answer(gridNo).flag(i) == 0 & answer(gridNo).flag(i+1) == 0 ...
	  & manFlag(i) ==0 & manFlag(i+1) == 0
      % Check if the spot has a large variance
      if sqrt(answer(gridNo).log2Var(i)) < 0.25 ...
	    & sqrt(answer(gridNo).log2Var(i+1)) < 0.25	
	
	counter = counter + 1;
	visResults(counter, :) = [answer(gridNo).log2Exp(i) ...
		    answer(gridNo).log2Exp(i+1)];
	visVarResults(counter, :) = [answer(gridNo).log2Var(i) ...
		    answer(gridNo).log2Var(i+1)];
	spotResults(counter, :) =  [spotLog2Ratio((gridNo-1)*numPerGrid + i) ...
		    spotLog2Ratio((gridNo-1)*numPerGrid + i+1)];
	manResults(counter, :) = [manLog2Ratio((gridNo-1)*numPerGrid + i) ...
		    manLog2Ratio((gridNo-1)*numPerGrid + i+1)];
      end
    end
  end
end


mseSpot = mean((spotResults(:, 1) - spotResults(:, 2)).^2);
mseVis = mean((visResults(:, 1) - visResults(:, 2)).^2);
mseMan = mean((manResults(:, 1) - manResults(:, 2)).^2);

limitVal = [-4 4];

% In figure 1 plot results from manual grid placement


figure(1)
clf
plot(manResults(:, 1), manResults(:, 2), 'r.')
set(gca, 'xtick', [-4 -2 2 4])
set(gca, 'ytick', [-4 -2 2 4])
prepareplot(limitVal);

figure(2)
clf
plot(visResults(:, 1), visResults(:, 2), 'r.')
set(gca, 'xtick', [-4 -2 2 4])
set(gca, 'ytick', [-4 -2 2 4])
prepareplot(limitVal);

figure(3)
clf
plot(spotResults(:, 1), spotResults(:, 2), 'r.')
set(gca, 'xtick', [-4 -2 2 4])
set(gca, 'ytick', [-4 -2 2 4])
prepareplot(limitVal);

limitVal = [-2 2];
figure(4)
clf
index = randperm(length(visResults(:))); 
errorbar(spotResults(index(1:50)), ...
	 visResults(index(1:50)), ...
	 sqrt(visVarResults(index(1:50))), 'rx')
set(gca, 'xtick', [-4 -2 2 4])
set(gca, 'ytick', [-4 -2 2 4])
prepareplot(limitVal);

