function ll = modelDataLnNorm(channelOne, channelTwo, index, gridSize, display);
% MODELDATALNNORM Model the foreground and background with a log normal.
% FORMAT
% DESC models the foreground pixel intensities and background pixel
% intensities with log normals.
% RETURN ll : the log likelihood
% ARG channelOne : the red channel.
% ARG channelTwo : the green channel.
% ARG indices : indices from the channels to be modelled.
% ARG gridSize : size of the original grid being modelled (rows and
% columns).
% ARG display : should be set to 0 for no display, 1 for text display and 2 for
% image display. The latter setting is useful for ensuring you have the
% parameters of the variational importance sampler set reasonably.
%
% COPYRIGHT : Neil D. Lawrence, 2001, 2003, 2007
%
% SEEALSO : createGridModel, modelDataHist
  
% VIS

I_max = 65535;


% Build the channel models
logSelectChannelOne = log(double(channelOne(index))+1);
muOne = mean(logSelectChannelOne);
varOne = var(logSelectChannelOne);

logSelectChannelTwo = log(double(channelTwo(index))+1);
muTwo = mean(logSelectChannelTwo);
varTwo = var(logSelectChannelTwo);

% Evaluate the likelihood
logChannelOne = log(double(channelOne)+1);
logChannelTwo = log(double(channelTwo)+1);
ll = -log(2*pi) - 1/2*log(varOne) -1/2*log(varTwo) ...
     - logChannelOne - logChannelTwo ...
     - 1/(2*varOne)*(logChannelOne - muOne).^2 ...
     - 1/(2*varTwo)*(logChannelTwo - muTwo).^2;

ll = reshape(ll, gridSize)';
