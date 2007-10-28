function oval = ovalpak(params, oval)

% OVALPAK Takes the parameters of a set of ovals and returns the ovals.

% VIS
  
oval.xradius = params(1, 3);
oval.yradius = params(1, 4);
oval.centre = params(1, 1:2);
