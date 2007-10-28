function oval = ovalcreate(centre, xradius, yradius, handle);

% OVALCREATE Create a struct containing the parameters of an oval.
% 
% oval = ovalcreate(centre, xradius, yradius, handle);
%
% version 0.1 
% Copyright (c) Neil Lawrence 2002

oval.xradius = xradius;
oval.yradius = yradius;
oval.selected = 0;
oval.centre = centre;
oval.handle = [];
if nargin > 3
  oval.handle = handle;
end
oval.controlPointHandle = [];
oval.type = 'oval';

