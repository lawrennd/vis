function saggrid = sagwrite(filename, saggrid)

% SAGWRITE this function takes a grid from matlab and writes it to a scanalyze grid file.

% VIS
  
% version 0.3
% Copyright (c) Neil Lawrence 2002,2003


fid = fopen(filename, 'w', 'ieee-le');
header = 'SGF3.1';
fwrite(fid, header, 'uchar');
numSaggrids = length(saggrid);
fwrite(fid, numSaggrids, 'int32');
for i = 1:numSaggrids
  fwrite(fid, saggrid(i).columns, 'int32');
  fwrite(fid, saggrid(i).rows, 'int32');
  fwrite(fid, saggrid(i).spotWidth, 'int32');
  fwrite(fid, saggrid(i).spotHeight, 'int32');
  fwrite(fid, saggrid(i).left, 'double');
  fwrite(fid, saggrid(i).top, 'double');
  fwrite(fid, saggrid(i).colX, 'double');
  fwrite(fid, saggrid(i).colY, 'double');
  fwrite(fid, saggrid(i).rowX, 'double');
  fwrite(fid, saggrid(i).rowY, 'double');
  % Returned to this way round for compatability with Scanalyze
  for j=1:saggrid(i).rows
    for k=1:saggrid(i).columns
      fwrite(fid, saggrid(i).rowOffset(j, k), 'int32');
      fwrite(fid, saggrid(i).columnOffset(j, k), 'int32');
      fwrite(fid, saggrid(i).widthOverride(j, k), 'int32');
      fwrite(fid, saggrid(i).heightOverride(j, k), 'int32');
      fwrite(fid, saggrid(i).flag(j, k), 'int32');
    end
  end
end

fclose(fid);






