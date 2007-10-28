% DEMPAPER3 This script recreates a Bioinformatics paper experiment.

% VIS

% Process the data given this grid
answer = processImage('SS6', 0);

% Save the results in a csv file
ratiocsvwrite('demoPaper3.csv', answer);

% Load manually placed flags showing where dust-spots are
sagFlag = sagread('SS6flag.sag');

% Load data extracted from spot
spotLog2Ratio = spotlog2('ss6_spot.dat');

% Number of spots in each grid
numPerGrid = 15*16;

counter = 0;
for gridNo = 1:length(answer)
  % storePoints for later analysis
  for i = 1:2:length(answer(gridNo).log2Exp)
    manFlag = sagFlag(gridNo).flag(:);
    
    if ((answer(gridNo).flag(i) == 0 | ...
	answer(gridNo).flag(i) == 3) ...
      & (answer(gridNo).flag(i+1) == 0 | ...
	 answer(gridNo).flag(i+1) == 3) ...
	  & manFlag(i) == 0 & manFlag(i+1) == 0)
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
	visRed(counter, :) = [answer(gridNo).redVals(i) answer(gridNo).redVals(i+1)];
	visGreen(counter, :) = [answer(gridNo).greenVals(i) answer(gridNo).greenVals(i+1)];
      end
    end
  end
end

% Do a rough normalisation
meanSpot = mean(spotResults(:));
meanVis = mean(visResults(:));

% COmpute error
mseSpot = mean((spotResults(:, 1) - spotResults(:, 2)).^2);
mseVis = mean((visResults(:, 1) - visResults(:, 2)).^2);

figure(1)
errorbar(spotResults(:)-meanSpot, visResults(:)-meanVis, 2*sqrt(visVarResults(:)), 'rx')
limitVal =[-4 4];
set(gca, 'xtick', [-4 -2 0 2 4])
set(gca, 'ytick', [-4 -2 0 2 4])

prepareplot(limitVal);



figure(2)
plot(spotResults(:, 1)-meanSpot, spotResults(:, 2)-meanSpot, 'rx')
limitVal =[-4 4];
set(gca, 'xtick', [-4 -2 0 2 4])
set(gca, 'ytick', [-4 -2 0 2 4])

prepareplot(limitVal);



figure(3)
plot(visResults(:, 1)-meanVis, visResults(:,2)-meanVis, 'rx')
limitVal =[-4 4];
set(gca, 'xtick', [-4 -2 0 2 4])
set(gca, 'ytick', [-4 -2 0 2 4])

prepareplot(limitVal);


