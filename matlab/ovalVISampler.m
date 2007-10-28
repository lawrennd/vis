function [ovals, weights] = ovalVISampler(origOval, likelihoodStruct, display); 
  
% OVALVISAMPLER Use the variational importance sampler to refine the oval positions.
% FOMAT
% DESC uses the variational imporatnce sampler to refine the positions of
% the ovals.
% ARG origOval : the orginal location of the ovals.
% ARG likelihoodStruct : the lieklihood structure to be passed to the
% variational importance sampler.
% ARG display : should be set to 0 for no display, 1 for text display and 2 for
% image display. The latter setting is useful for ensuring you have the
% parameters of the variational importance sampler set reasonably.
% RETURN ovals : the sampled ovals.
% RETURN weights : the imporance weights for the sampled ovals.
%
% COPYRIGHT : Neil D. Lawrence, 2003, 2007
%
% SEEALSO : ovalpak, viSampler, processImage, ovalLikelihood

% VIS

priors{1}.dim = 2;
priors{1}.mu = origOval.centre; % The mean of the centres prior 
centreSD = 2; % The standard deviation of centres prior
priors{1}.precision = eye(priors{1}.dim)*1/(centreSD*centreSD);    % The precision of the centres prior
priors{1}.nu = 5.1;         % The degrees of freedom of the centre's
                            % wishart distribution
nuStudentT = priors{1}.nu - priors{1}.dim-1;			    
priors{1}.S_inv =  (nuStudentT  - 2)*eye(priors{1}.dim)/nuStudentT; % The covariance of the centre's wishart distribution


priors{2}.dim = 2;
priors{2}.mu(1) = origOval.xradius;
priors{2}.mu(2) = origOval.yradius;
correlatedRadiusSD = 2; % The standard deviation of the radii prior
anticorrelatedRadiusSD = 0.5;
eigVectors = [sqrt(2)/2 sqrt(2)/2; sqrt(2)/2 -sqrt(2)/2];
eigVals = 1./[correlatedRadiusSD^2 anticorrelatedRadiusSD^2];
priors{2}.precision = eigVectors*diag(eigVals)*eigVectors';      % The precision of the radii prior 
priors{2}.nu  = 5.1;        % The degrees of freedom of the centre's wishart distribution
nuStudentT = priors{2}.nu - priors{2}.dim-1;			    
priors{2}.S_inv = (nuStudentT - 2)*eye(priors{2}.dim)/nuStudentT; % The inverse covariance of the radii's wishart distribution

% Set the limits of the box within which the likelihood function is calculated
    
numSamps = 100;
maxIters = 20;  

options(1) = display;
options(2) = numSamps; % Number of Samples
options(3) = maxIters;              % Maximum number of iterations
options(4) = 10; % max iterations in the inner (quicker) loop

oval = ovalcreate(priors{1}.mu, priors{2}.mu(1), priors{2}.mu(2));
% group One is centres, group 2 is the radii
[samples, weights] = viSampler('ovalLikelihood', [ones(1, 2) ones(1, 2)*2], ...
			       options, priors, ...
			       oval, likelihoodStruct); 

for i = 1:size(samples, 1)
  ovals(i) = ovalpak(samples(i, :), oval);
end
if display > 1
  ovals = ovaldraw(ovals);
  if length(ovals) ==1 
    set(ovals.handle, 'color', [1 0 0])
  end
end