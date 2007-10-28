function params = ovalunpak(ovals)

% OVALUNPAK Take an array of ovals and convert into a matrix of their parameters.

% VIS
  
numOvals = length(ovals);
params = zeros(numOvals, 8);

for i = 1:numOvals
  params(i, 1:2) = ovals(i).centre;
  params(i, 3) = ovals(i).xradius;
  params(i, 4) = ovals(i).yradius;
end
