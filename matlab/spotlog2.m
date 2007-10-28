function log2Ratio = spotlog2(fileName)

% SPOTLOG2 Helper function to get log2 ratio from a spot file.

% VIS
  
%
% log2Ratio = spotlog2(fileName)
%
% version 0.1 
% Copyright (c) Neil Lawrence 2002

% scanalyze starts writing the data at row 8 column 1
spotData = dlmread(fileName, ' ', 1, 0);


% The red values are in column 18 and 11
redBackground = spotData(:, 18);
redForeground = spotData(:, 11);

% The signal is the foreground minus the background
redSignal = redForeground - redBackground;

% Remove the negative values, set them to 1
redSignal(find(redSignal<=0)) = 1;

greenBackground = spotData(:, 15);
greenForeground = spotData(:, 8);

greenSignal = greenForeground - greenBackground;
greenSignal(find(greenSignal<=0)) = 1;

% The log2 ratio is the difference of the log of the signals
log2Ratio = log2(redSignal) - log2(greenSignal);
