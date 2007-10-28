function [samples, weights] = viSampler(likelihoodFunc, groupAllocations, ...
					options, priors, object, varargin); 
  
% VISAMPLER The variational imporatnce sampler.
% FORMAT
% DESC given a likelihood function and allocations of groups this
% function computes the variational importance sampler.
% ARG likelihoodFunc : the likelihood function that the variational
% importance sampler calls.
% ARG groupAllocations : the allocation of indices to parameters.
% ARG options : options vector, display is first element, numSamples is
% second element, max outer iterations is third element, max inner
% iterations is fourth element. 
% ARG priors : the prior distributions.
% ARG object : the shape for which sampling is done.
% ARG P1, P2, P3 ... : extra arguments for the likelihood function.
%
% COPYRIGHT : Neil D. Lawrence, 2003
%
% SEEALSO : 

% VIS

% 
% version 0.3 
% Copyright (c) Neil Lawrence 2003

display = options(1);
numSamps = options(2);
maxIters = options(3);              
innerIters = options(4);
numGroups = length(priors);
numParams = length(groupAllocations);

% Get the indices of the parameters for each group
for group = 1:numGroups
  groupIndices{group} = find(groupAllocations==group);
end
minIters = 3;
% Set inital values
for group = 1:numGroups
  mbar{group} = priors{group}.mu;
  Sigma{group} = 1/(priors{group}.nu+1)*(priors{group}.S_inv + 2*pdinv(priors{group}.precision));
  exp_P{group} = pdinv(Sigma{group});
end

for iters = 1:maxIters  
  for group = 1:numGroups
    samples(:, groupIndices{group}) = gsamp(mbar{group}, Sigma{group}, numSamps);
  end
  % Display objects
  if display > 1
    if iters > 1
      objectdelete(objects);
    end
    for i = 1:numSamps
      objects(i) = objectpak(samples(i, :), object);
    end
    objects = objectdraw(objects);
    drawnow
  end
    
  sampl = feval(likelihoodFunc, samples, object, varargin{:});
  maxSampl = max(sampl);
  if maxSampl < 0 & iters >= minIters
    if display > 1
      objectdelete(objects);
    end
    samples = objectunpak(object);
    weights = 1;
    if display
      fprintf('After %i iterations no object found\n', iters);
    end
    break
    
  end
  % Normalise the likelihoods into importance weights
  sampl = sampl - maxSampl;
  sampl = exp(sampl);
  weights = sampl/sum(sampl);
  for group = 1:numGroups
    exp_param{group} = zeros(1, sum(groupAllocations==group));
    exp_paramparamT{group} = zeros(sum(groupAllocations == group));
    for i = 1:numSamps
      groupParams = samples(i, groupIndices{group});
      exp_param{group} = exp_param{group} + groupParams*weights(i);
      exp_paramparamT{group} = exp_paramparamT{group} ...
	  + groupParams'*groupParams*weights(i);
    end
  end
  
  for i = 1:innerIters

    for group = 1:numGroups
      mbar{group} = (exp_param{group}*exp_P{group} + priors{group}.mu*priors{group}.precision)*Sigma{group};
      exp_m{group} = mbar{group};
      exp_mmT{group} = Sigma{group} + mbar{group}'*mbar{group};
    
      Sbar_inv{group} = priors{group}.S_inv ...
	+ exp_paramparamT{group} - exp_param{group}'*exp_m{group} ...
	- exp_m{group}'*exp_param{group} + exp_mmT{group};
      nubar{group} = priors{group}.nu + 1;
      exp_P{group} = nubar{group}*pdinv(Sbar_inv{group});
      Sigma{group} = pdinv(exp_P{group} + priors{group}.precision);
      exp_mmT{group} = Sigma{group} + mbar{group}'*mbar{group};
    end
  end
  % A hacky convergence criterium --- converge when effective number of
  % samples is greater than a quarter of the total
  effSamps = (1/sum(weights.*weights));
  if  effSamps > numSamps/2 & iters >= minIters;
    break
  end
%  if display
%    fprintf('Iter %i, Effective samples %2.2f.\n', iters, effSamps);
%  end
end

if display
  if iters == maxIters
    fprintf('Max iters exceeded, ');
  else
    fprintf('After iteration %i, ', iters);
  end
  fprintf('Effective number of samples %2.2f.\n', (1/sum(weights.*weights)))
end


