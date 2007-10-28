function log2Ratio = scanalyzelog2(fileName)

% SCANALYZELOG2 Helper function to get log2 ratio from a scanalyze file

% VIS
  
% version 0.1 
% Copyright (c) Neil Lawrence 2002

% scanalyze starts writing the data at row 8 column 1
r1Data = dlmread(fileName, '\t', 8, 1);

% The red values are in column 13 and 12
redBackground = r1Data(:, 13);
redForeground = r1Data(:, 12);

% The signal is the foreground minus the background
redSignal = redForeground - redBackground;

% Remove the negative values, set them to 1
redSignal(find(redSignal<=0)) = 1;

greenBackground = r1Data(:, 10);
greenForeground = r1Data(:, 9);

greenSignal = greenForeground - greenBackground;
greenSignal(find(greenSignal<=0)) = 1;

% The log2 ratio is the difference of the log of the signals
log2Ratio = log2(redSignal) - log2(greenSignal);

