function sampl = ovalll(ovals, limitsx, limitsy,  redChannel, greenChannel, redbackHist, ...
		     greenbackHist, redforeHist, greenforeHist)

% OVALLL Evaluate the log likelihood of hypothesised ovals.
% FORMAT
% DESC evaluates the log lieklihood of a set of hypothesised ovals.
% ARG ovals : structure containing ovals to evaluate.
% ARG limitsx : together with limitsy specifies the region of the image in which the oval is expected.
% ARG limitsy : together with limitsx specifies the region of the image in which the oval is expected.
% ARG redChannel : the red channel from the array image
% ARG greenChannel : the green channel from the array image
% ARG redbackHist : a histogram representing the red background
% ARG greenbackHist : a histogram representing the green background
% ARG redforeHist : a histogram representing the red foreground
% ARG greenforeHist : a histogram representing the green foreground
%
% This function is implemented as a mex file. See ovalll.cpp
%
% COPYRIGHT : Neil D. Lawrence, 2002
%
% SEEALSO : ovalLikelihood

% VIS

