function [iSub, jSub] = ovalsubscript(ovals)

% OVALSUBSCRIPT Returns the subscripts of any pixels that would fall inside the oval
%
% [iSub, jSub] = ovalSubscript(ovals);
%
% Where ovals is a single or array of structs with members
%
%   'type' - set equal to 'oval'.
%   'centre' - set equal to the centre of the oval.
%   'xradius' - the radius of the oval in the x direction.
%   'yradius' - the radius of the oval in the y direction.
%
% And iSub and jSub contain the indexes of pixels which fall within the
% oval.  
%
% Version 0.1
% Copyright (c) Neil Lawrence 2001

maxArea = 0;
for i = 1:length(ovals)
  maxArea = maxArea + 4*ovals(i).xradius*ovals(i).yradius;
end
iSub = zeros(ceil(maxArea), 1);
jSub = zeros(ceil(maxArea), 1);
counter = 0;

for i = 1:length(ovals)
  
  % Get left and right of circle
  leftSquare = floor(ovals(i).centre(1) - ovals(i).xradius);
  rightSquare = ceil(ovals(i).centre(1) + ovals(i).xradius);
  xRadius2 = (ovals(i).xradius*ovals(i).xradius);
  % Find index of pixels whose centre is within the circle
  for x = leftSquare:rightSquare
    xPos = x - ovals(i).centre(1); % Centre of x pixel    
    xPart = (xPos*xPos)/xRadius2;
    if xPart <= 1
       yPos = sqrt((1 - xPart))*ovals(i).yradius;
       yStart = round(ovals(i).centre(2) - yPos);
       yEnd = round(ovals(i).centre(2) + yPos); 
       yPoints = (yStart:yEnd)';
       numPoints = length(yPoints);
       iSub((counter+1):(counter+numPoints)) = yPoints;
       jSub((counter+1):(counter+numPoints)) = x;
       counter = counter + numPoints;
    end
  end
end
iSub = iSub(1:counter)';
jSub = jSub(1:counter)';

