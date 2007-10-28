function grid = sagread(filename)

% SAGREAD This function loads a scanalyze SAG file into a structure in MATLAB.
% FORMAT
% DESC reads a microarray grid file in the SAG format into MATLAB.
% ARG fileName : the filename to read in.
% RETURN grid : the grid storage.
%
% COPYRIGHT : Neil D. Lawrence, 2002, 2003, 2007
%
% SEEALSO : sagwrite

% VIS
  
fid = fopen(filename, 'r', 'ieee-le');
header = fread(fid, 6, 'uchar');
header = char(header');

switch header

 case 'SGF3.1' % Code based on ScanAlyze Master.cpp
  numGrids = fread(fid, 1, 'int32');
  for i = 1:numGrids
    grid(i).type = 'saggrid';
    grid(i).columns = fread(fid, 1, 'int32');
    grid(i).rows = fread(fid, 1, 'int32');
    grid(i).spotWidth = fread(fid, 1, 'int32');
    grid(i).spotHeight = fread(fid, 1, 'int32');
    grid(i).left = fread(fid, 1, 'double');
    grid(i).top = fread(fid, 1, 'double');
    grid(i).colX = fread(fid, 1, 'double');
    grid(i).colY = fread(fid, 1, 'double');
    grid(i).rowX = fread(fid, 1, 'double');
    grid(i).rowY = fread(fid, 1, 'double');
    grid(i).rowOffset = zeros(grid(i).rows, grid(i).columns);
    grid(i).columnOffset = zeros(grid(i).rows, grid(i).columns);
    grid(i).widthOverride = zeros(grid(i).rows, grid(i).columns);
    grid(i).heightOverride = zeros(grid(i).rows, grid(i).columns);
    grid(i).flag = zeros(grid(i).rows, grid(i).columns);
    for j=1:grid(i).rows
      for k=1:grid(i).columns
	grid(i).rowOffset(j, k) = fread(fid, 1, 'int32');
	grid(i).columnOffset(j, k) = fread(fid, 1, 'int32');
	grid(i).widthOverride(j, k) = fread(fid, 1, 'int32');
	grid(i).heightOverride(j, k) = fread(fid, 1, 'int32');
	grid(i).flag(j, k) = fread(fid, 1, 'int32');
      end
    end
  end
 
 case 'SGF2.0' % Code based on ScanAlyze Master.cpp
  numGrids = fread(fid, 1, 'int32');
  for i = 1:numGrids
    grid(i).type = 'saggrid';
    grid(i).columns = fread(fid, 1, 'int32');
    grid(i).rows = fread(fid, 1, 'int32');
    grid(i).spotWidth = fread(fid, 1, 'int32');
    grid(i).spotHeight = fread(fid, 1, 'int32');
    
    % TRect Structure
    gridRect.left = fread(fid, 1, 'long');
    gridRect.top = fread(fid, 1, 'long');
    gridRect.right = fread(fid, 1, 'long');
    gridRect.bottom = fread(fid, 1, 'long');
    
    tiltAngle = fread(fid, 1, 'double');
    
    % POINT Structure
    warp.x = fread(fid, 1, 'long');
    warp.y = fread(fid, 1, 'long');

    % Translation to our format done through ScanAlyze code in Grids.cpp
    colSpaces = max(1,grid(i).columns-1);
    rowSpaces = max(1,grid(i).rows-1);

    grid(i).left = gridRect.left;
    grid(i).top = gridRect.top;


    colX = (gridRect.right - gridRect.left)/colSpaces;
    colY = 0;
    rowX = 0;
    rowY = (gridRect.bottom - gridRect.top)/rowSpaces;    

    colX = colX + warp.x / colSpaces;
    colY = colY + warp.y / colSpaces;
    rowX = rowX - warp.x / rowSpaces;
    rowY = rowY - warp.y / rowSpaces;

    X = colX;
    Y = colY;

    colX = X * cos(tiltAngle) - Y * sin(tiltAngle);
    colY = Y * cos(tiltAngle) + X * sin(tiltAngle);

    X = rowX;
    Y = rowY;

    rowX = X * cos(tiltAngle) - Y * sin(tiltAngle);
    rowY = Y * cos(tiltAngle) + X * sin(tiltAngle);

    grid(i).colX = colX;
    grid(i).colY = colY;
    grid(i).rowX = rowX;
    grid(i).rowY = rowY;

    grid(i).rowOffset = zeros(grid(i).rows, grid(i).columns);
    grid(i).columnOffset = zeros(grid(i).rows, grid(i).columns);
    grid(i).widthOverride = zeros(grid(i).rows, grid(i).columns);
    grid(i).heightOverride = zeros(grid(i).rows, grid(i).columns);
    grid(i).flag = zeros(grid(i).rows, grid(i).columns);

    for j=1:grid(i).rows
      for k=1:grid(i).columns
	grid(i).rowOffset(j, k) = fread(fid, 1, 'int32');
	grid(i).columnOffset(j, k) = fread(fid, 1, 'int32');
	grid(i).widthOverride(j, k) = fread(fid, 1, 'int32');
	grid(i).heightOverride(j, k) = fread(fid, 1, 'int32');
	grid(i).flag(j, k) = fread(fid, 1, 'int32');
      end
    end
  end
 otherwise
  fclose(fid);
  error('Unrecognised file type')
end
fclose(fid);






