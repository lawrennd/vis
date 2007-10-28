% DEMPAPER1 This script recreates the first Bioinformatics paper experiment.

% VIS

% This script runs the vis algorithm on the SS1 slide twice, initialising
% with the grid placement of two different researchers.


% Load the grid from researcher 1
tempSagGrids = sagread('./data/R1SS1.sag');

% Write the result to SS1.sag for processing
sagwrite('./data/SS1.sag', tempSagGrids);

% Process the data given this grid
[answer1, grid1] = processImage('./data/SS1', 0);

% Save the results in a csv file
ratiocsvwrite('firstResults.csv', answer1);

% Load the grid from researcher 2
tempSagGrids = sagread('./data/R2SS1.sag');

% Write the result to SS1.sag for processing
sagwrite('./data/SS1.sag', tempSagGrids);

% Process the data given this grid
[answer2, grid2] = processImage('./data/SS1', 0);

% Save the results in a csv file
ratiocsvwrite('secondResults.csv', answer2)

% Load data from scanalyze for researcher 1
r1Log2Ratio = scanalyzelog2('./data/R1SS1.dat');
% Load data from scanalyze for researcher 2
r2Log2Ratio = scanalyzelog2('./data/R2SS1.dat');

% Number of spots in each grid
numPerGrid = 256;


counter = 0;
for i = 1:length(answer1)
  for j = 1:length(answer1(i).log2Exp)

    % check whether spot has been flagged at all
    if answer1(i).flag(j) == 0 ...
	  & answer2(i).flag(j) == 0

      % Check if the spot has a large variance
      if sqrt(answer1(i).log2Var(j)) < 0.25 ...
	    & sqrt(answer2(i).log2Var(j)) < 0.25	

	% store points for later analysis
	counter = counter + 1;
	visResults(counter, :) = [answer1(i).log2Exp(j) ...
		    answer2(i).log2Exp(j)];
	manResults(counter, :) = [r1Log2Ratio((i-1)*numPerGrid + j) ...
		    r2Log2Ratio((i-1)*numPerGrid + j)];
	visVarResults(counter, :) = [answer1(i).log2Var(j) ...
		    answer2(i).log2Var(j)];
	intensityResults(counter, :) = [answer1(i).redVals(j).*answer1(i).greenVals(j) ...
		    answer2(i).redVals(j).*answer2(i).greenVals(j)];

      end
    end
  end
end

% Compute mean square errors
mseVis = mean((visResults(:, 1) - visResults(:, 2)).^2);
mseMan = mean((manResults(:, 1) - manResults(:, 2)).^2);

limitVal = [-8 8];

% In figure 1 plot results from manual grid placement
figure(1)
clf
plot(manResults(:, 1), manResults(:, 2), '.');
set(gca, 'xtick', [-8 -4 4 8])
set(gca, 'ytick', [-8 -4 4 8])
prepareplot(limitVal);

% In figure 2 plot the results from vis
figure(2)
clf
plot(visResults(:, 1), visResults(:, 2), '.');
set(gca, 'xtick', [-8 -4 4 8])
set(gca, 'ytick', [-8 -4 4 8])
prepareplot(limitVal);


figure(3)
clf
plot(log10(intensityResults(:)), log10(visVarResults(:)), 'r.')
set(gca, 'xlim', [5 8])
set(gca, 'xtick', [5 6 7 8])
set(gca, 'ytick', [-6 -1])
set(gca, 'ytick', [-6 -5 -4 -3 -2 -1])
xlab = xlabel('log_{10} intensity');
set(xlab, 'fontname', 'times');
set(xlab, 'fontsize', 18);
ylab = ylabel('log_{10} of variance of log_2 ratio')
set(ylab, 'fontname', 'times');
set(ylab, 'fontsize', 18);
set(gca, 'fontname', 'times')
set(GCA, 'fontsize', 16)