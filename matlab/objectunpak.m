function params = objectunpak(object)

% OBJECTUNPAK Take an object's parameters and create objects from them.

% VIS

params = feval([object.type 'unpak'], object);

