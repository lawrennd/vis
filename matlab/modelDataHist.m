function ll = modelDataHist(channelOne, channelTwo, index, gridSize, display);

% MODELDATAHIST Model the foreground and background with a histogram.
% FORMAT
% DESC models the foreground pixel intensities and background pixel
% intensities with histograms.
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
% SEEALSO : createGridModel, modelDataLnNorm

% VIS

I_max = 65535;

% Extract the red background image pixels and histogram.
channelOneHist = histogcreate(double(channelOne(index)), 0, I_max, 30, 1);
channelOneHist.height = (channelOneHist.height*length(index) + ...
		      1/(I_max*channelOneHist.width))/(length(index) + 1);

% Extract the green background image pixels and histogram.
channelTwoHist = histogcreate(double(channelTwo(index)), 0, I_max, 30, 1);
channelTwoHist.height = (channelTwoHist.height*length(index) + ...
			1/(I_max*channelTwoHist.width))/(length(index) + 1);


ll = histogll(channelOneHist, double(channelOne)) + histogll(channelTwoHist, double(channelTwo));

ll = reshape(ll, gridSize)';

function ll = histogll(histog, data)

% HISTOGLL Compute log likelihood of each data point under a histogram.

ll = zeros(size(data));
logProb = 0;
start = min(histog.centres)-histog.width/2;
finish = max(histog.centres)+histog.width/2;
fullIndices = 1:length(ll);

index = find(data>finish | data < start);
if(~isempty(index))
  ll(index) = -inf;
  fullIndices(index) = [];
  data(index) = [];
  return
end
for i = 1:length(histog.centres)
  tindex = find(data>(histog.centres(i) - histog.width/2) ...
	       & data <= (histog.centres(i) + histog.width/2));
  index = fullIndices(tindex);
  ll(index) = log(histog.height(i));
  
  fullIndices(tindex) = [];
  data(tindex) = [];
end
