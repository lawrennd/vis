function histog = histogcreate(data, start, finish, nbins, priorCount)

% HISTOGCREATE Creates a histogram between a specified range.

% VIS
  
% Vs 0.3 Copyright (c) Neil Lawrence 2001, 2003

if nargin < 5 
  priorCount = 0;
end
histog.ncentres = nbins;
histog.width = (finish - start)/(nbins);
histog.centres = (start+histog.width/2:histog.width:finish-histog.width/2);
[histog.height, histog.centres] = hist(data, histog.centres);
histog.height = histog.height + priorCount;
histog.height = histog.height/sum(histog.height);
histog.height = histog.height/histog.width;
if nargout == 0
  bar(histog.centres, histog.height);
end
