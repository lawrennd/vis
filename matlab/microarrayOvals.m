function [ovals, importanceWeights] = microarrayOvals(imageData, centrePrior, radiusPrior, ...
						  maxWidth, maxHeight, ...
						  lowerBackground, upperBackground, dustSpotPoint, ...
						  numSamps, display, maxIters, ...
						  pauseTrue);
  % MICROARRAYOVALS 
if nargin < 12
  pauseTrue = 0;
end
if nargin < 11
  maxIters = 20;
end
if nargin < 10
  display = 0;

end
% Initialise the centre's parameters
mbar_c = centrePrior.mu;
Sigma_c = inv(eye(2)*centrePrior.beta);

% Initialise the radii's parameters
mbar_r = radiusPrior.mu;
Sigma_r = inv(eye(2)*radiusPrior.beta);

% Initialise the centre's moments
exp_Pc = (centrePrior.nu+1)*inv(centrePrior.S_inv + 2*Sigma_c);

% Initialise the radii's moments
exp_Pr = (radiusPrior.nu+1)*inv(radiusPrior.S_inv + 2*Sigma_r);



% Set the limits of the box within which the likelihood function is calculated
limitsx = [round(centrePrior.mu(1) - maxWidth/2) ...
	   round(centrePrior.mu(1) + maxWidth/2)];
limitsy = [round(centrePrior.mu(2) - maxHeight/2) ...
	   round(centrePrior.mu(2) + maxHeight/2)];


for iters = 1:maxIters

  
  mbar = [mbar_c mbar_r];
  Sigma = [inv(exp_Pc) zeros(2); zeros(2) inv(exp_Pr)];
  if iters == 1
    ovals = ovalsample(mbar, Sigma, numSamps);
  else
    ovals = ovalsample(mbar, Sigma, numSamps, ovals);
  end
  % Add an oval with no pixels in it.
  ovals(end+1) = ovalcreate(centrePrior.mu, 0, 0);
  sampl = ovalll(ovals, imageData);
  if iters > 2 & max(sampl) == sampl(end)
    objectdelete(ovals);
    ovals = ovalcreate(centrePrior.mu, radiusPrior.mu(1), ...
		       radiusPrior.mu(2));
    ovals(end).selected = 0;
    if display > 1
      ovals = ovaldraw(ovals);
      set(ovals(end).handle, 'color', [1 0 0])
    end
    importanceWeights = 1;
    break
  end
  % Throw away the oval with no pixels in it.
  sampl = sampl(1:end-1);
  ovals = ovals(1:end-1);
  if display > 1
    [sampl, order] = sort(sampl);
    ovals = ovals(order);
    ovals = ovaldraw(ovals);
  end
  % Normalise the likelihoods into importance weights
  sampl = sampl - max(sampl);
  sampl = exp(sampl);
  importanceWeights = sampl/sum(sampl);
  
  
  if display > 1
    if pauseTrue
      for i = 1:numSamps
	if numSamps*importanceWeights(i) < 1
	  set(ovals(i).handle, 'color', [1 0 0])
	  set(ovals(i).handle, 'lineWidth', 1)
	else
	  objectdelete(ovals(i));
	  ovals(i) = ovaldraw(ovals(i));
	  set(ovals(i).handle, 'color', [1 1 0])
          if importanceWeights(i)>0
            set(ovals(i).handle, 'linewidth', log(importanceWeights(i)* ...
                                                  numSamps));
          else
            set(ovals(i).handle, 'visible', 'off')
          end
	  
	end
      end	
      disp('Press any key')
      pause
    else
      for i = 1:numSamps
	if numSamps*importanceWeights(i) < 1
	  set(ovals(i).handle, 'visible', 'off')
	else
	  set(ovals(i).handle, 'visible', 'on')
	end
      end
      drawnow
    end
  end
  exp_c = zeros(1, 2);
  exp_ccT = zeros(2);
  
  exp_r = zeros(1, 2);
  exp_rrT = zeros(2);
  
  for i = 1:numSamps
    exp_c = exp_c + importanceWeights(i)*ovals(i).centre;
    exp_ccT = exp_ccT + importanceWeights(i)*ovals(i).centre'* ...
	      ovals(i).centre;
    
    rad = [ovals(i).xradius ovals(i).yradius];
    exp_r = exp_r + importanceWeights(i)*rad;
    exp_rrT = exp_rrT + importanceWeights(i)*rad'*rad;
  end
  

  for i = 1:10
    % Update posterior of centre's mean
    mbar_c = (exp_c*exp_Pc + centrePrior.beta*centrePrior.mu)*Sigma_c;
    exp_mc = mbar_c;
    exp_mcmcT = Sigma_c + mbar_c'*mbar_c;
    
    % Update posterior of centre's precision matrix
    Sbar_c_inv = centrePrior.S_inv ...
	+ exp_ccT - exp_c'*exp_mc ...
	- exp_mc'*exp_c + exp_mcmcT;
    nubar_c = centrePrior.nu + 1;
    exp_Pc = nubar_c*inv(Sbar_c_inv);
    Sigma_c = inv(exp_Pc + centrePrior.beta*eye(2));
    exp_mcmcT = Sigma_c + mbar_c'*mbar_c;
    % Update posterior of radii's mean
    mbar_r = (exp_r*exp_Pr + radiusPrior.beta*radiusPrior.mu)*Sigma_r;
    exp_mr = mbar_r;
    exp_mrmrT = Sigma_r + mbar_r'*mbar_r;

    % Update posterior of radii's precision matrix
    Sbar_r_inv = radiusPrior.S_inv ...
	+ exp_rrT - exp_r'*exp_mr ...
	- exp_mr'*exp_r + exp_mrmrT;
    nubar_r = radiusPrior.nu + 1;
    exp_Pr = nubar_r*inv(Sbar_r_inv);
    Sigma_r = inv(exp_Pr + radiusPrior.beta*eye(2));
    exp_mrmrT = Sigma_r + mbar_r'*mbar_r;
    
  end
    
  % A hacky convergence criterium
  sigImport = (1/sum(importanceWeights.*importanceWeights));
  if  sigImport > numSamps/4;
    break
  end
end

if display>1
  if iters == maxIters
    fprintf('Max iters exceeded, ');
  else
    fprintf('After iteration %i, ', iters);
  end
  if length(ovals) > 1
    fprintf('Effective number of samples %2.2f.\n', (1/sum(importanceWeights.*importanceWeights)))
  else
    fprintf(['No spot found.\n'])
  end
end

