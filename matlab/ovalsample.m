function ovals = ovalsample(mu, Sigma, numSamps, ovals)

% OVALSAMPLE Sample an oval.
%
% ovals = ovalsample(mu, Sigma, numSamps)
% mu - 1x4 vector containing center mean and radius mean
% Sigma - 4x4 matrix containing covariance
% numSamps - the number of samples to take
%
% version 0.1 
% Copyright (c) Neil Lawrence 2002

values = gsamp(mu, Sigma, numSamps);

if nargin > 3
  for i= 1:numSamps
    ovals(i).selected = 0;
    ovals(i).centre(1) = values(i, 1);
    ovals(i).centre(2) = values(i, 2);
    ovals(i).xradius = values(i, 3);
    ovals(i).yradius = values(i, 4);
  end
else
  for i = 1:numSamps
    ovals(i) = ovalcreate([values(i, 1) values(i, 2)], ...
	values(i, 3), values(i, 4));
    ovals(i).selected = 0;
  end
end