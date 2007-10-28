function ovals = ovaldraw(ovals);

% OVALDRAW Function for drawing an oval from an array of oval structures.
% ovals = ovaldraw(ovals)
%
% version 0.1 
% Copyright (c) Neil Lawrence 2002

t = 0:pi/24:2*pi;
for i = 1:length(ovals)
  x = ovals(i).centre(1)*ones(size(t)) + ovals(i).xradius*sin(t);
  y = ovals(i).centre(2)*ones(size(t)) + ovals(i).yradius*cos(t);
  try
    if isempty(ovals(i).handle)
      ovals(i).handle = line(x', y');
    else
      set(ovals(i).handle, 'XData', x', 'YData', y');
    end
  catch
    ovals(i).handle = line(x', y');
  end
  if ovals(i).selected
    try
     if isempty(ovals(i).handle)
       ovals(i).controlPointHandle(1) = line(ovals(i).centre(1), ...
					     ovals(i).centre(2));
       ovals(i).controlPointHandle(2) = line(ovals(i).centre(1)+ovals(i).xradius, ...
					     ovals(i).centre(2));
       ovals(i).controlPointHandle(3) = line(ovals(i).centre(1), ...
					     ovals(i).centre(2)+ovals(i).yradius);
       set(ovals(i).controlPointHandle(:), 'Marker', '.', ...
			 'MarkerSize', 20, ...
			 'LineStyle', 'none', ...
			 'EraseMode', 'xor');
     end
      set(ovals(i).controlPointHandle(1), ...
	  'XData', ovals(i).centre(1), ...
	  'YData', ovals(i).centre(2));
      set(ovals(i).controlPointHandle(2), ...
	  'XData', ovals(i).centre(1)+ovals(i).xradius, ...
	  'YData', ovals(i).centre(2));
      set(ovals(i).controlPointHandle(3), ...
	  'XData', ovals(i).centre(1), ...
	  'YData', ovals(i).centre(2)+ovals(i).yradius);
      set(ovals(i).controlPointHandle, 'Visible', 'on')
    catch
      ovals(i).controlPointHandle = [];
      ovals(i).controlPointHandle(1) = line(ovals(i).centre(1), ...
					    ovals(i).centre(2));
      ovals(i).controlPointHandle(2) = line(ovals(i).centre(1)+ovals(i).xradius, ...
					    ovals(i).centre(2));
      ovals(i).controlPointHandle(3) = line(ovals(i).centre(1), ...
					    ovals(i).centre(2)+ovals(i).yradius);
      set(ovals(i).controlPointHandle(:), 'Marker', '.', ...
			'MarkerSize', 20, ...
			'LineStyle', 'none', ...
			'EraseMode', 'xor');
    end
  else
    try
      set(ovals(i).controlPointHandle, 'Visible', 'off')
    catch
    end
  end
end


