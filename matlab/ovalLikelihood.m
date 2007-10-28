function ll = ovalLikelihood(params, oval, likelihoodStruct);

% OVALLIKELIHOOD Computes the likelihood of an oval given an integral image.
% FORMAT
% DESC returns the likelihood associated with a set of ovals.
% ARG params : the parameters of the ovals.
% ARG oval : the structure of the ovals.
% ARG likelihoodStruct : the likelihood structure to be passed on to
% ovalll.
% RETURN ll : the returned log likelihood.
%
% COPYRIGHT : Neil D. Lawrence, 2003
% 
% SEEALSO : ovalll
  
% VIS
  
for i = 1:size(params, 1)
  ovals(i) = ovalpak(params(i, :), oval);
end
% Call c++ function for speed.
ll = ovalll(ovals, likelihoodStruct);
