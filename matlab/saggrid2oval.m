function ovals = saggrid2oval(saggrids)

% SAGGRID2OVAL Converts a saggrid into ovals.
% FORMAT
% DESC this function takes an array of
% structures which represents grids in the scanalyze grid format and
% converts them into an array of oval structures.

% VIS
  
% version 0.3 
% Copyright (c) Neil Lawrence 2002

counter = 0;
for i = 1:length(saggrids)
  points = saggridpoints(saggrids(i));
  if isfield(saggrids(i), 'widthOverride') & isfield(saggrids(i), ...
						     'heightOverride')
    override = 1;
  else
    override = 0;
  end
    
  for j = 1:saggrids(i).rows
    for k = 1:saggrids(i).columns
      counter = counter + 1;
      radiusX = saggrids(i).spotWidth/2;
      radiusY = saggrids(i).spotHeight/2;
      if override
	if saggrids(i).widthOverride(j, k)
	  radiusX = saggrids(i).widthOverride(j, k)/2;
	end
	if saggrids(i).heightOverride(j, k)
	  radiusY = saggrids(i).heightOverride(j, k)/2;
	end
      end
      ovals(counter) = ovalCreate(points(counter, :), radiusX, radiusY);
      ovals(counter).selected = 0;
    end
  end
end

