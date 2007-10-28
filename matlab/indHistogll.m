function ll = indHistogll(histog, data)

% INDHISTOGLL Compute the log-likelihood of a histogram, assuming data is indpendently sampled.

% VIS
LOGOFZERO = -328.0;

% Sort in ascending order
numData = length(data);
[sortData, sortIndex] = sort(data);
sortll = zeros(size(sortData));
ll = zeros(size(sortData));
i = 1;
binNo = 1;
while i <= numData & sortData(i) < histog.centres(binNo) - histog.width/2;
  i = i + 1;
end
sortll(1:i-1) = LOGOFZERO;
lasti = i;

while binNo <= length(histog.centres)
  binEnd = histog.centres(binNo) + histog.width/2;
  while(i <= numData & sortData(i) < binEnd) 
    i = i + 1;
  end
  if histog.height(binNo) == 0
    sortll(lasti:i-1) = LOGOFZERO;
  else
    sortll(lasti:i-1) = log(histog.height(binNo)) + log(histog.width);
  end
  binNo = binNo + 1;
  lasti = i;
end

if lasti ~= length(sortData)
  sortll(lasti:end) = LOGOFZERO;
end

ll(sortIndex) = sortll;
