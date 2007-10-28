function objects = objectpak(params, object)

% OBJECTPAK Take an object's parameters and create objects from them.

% VIS

objects = feval([object.type 'pak'], params, object);

