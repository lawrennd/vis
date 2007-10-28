function objects = objectpak(params, object)

% OBJECTPAK Take an object's parameters and create objects from them.


objects = feval([object.type 'pak'], params, object);

