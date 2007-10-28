function object = objectdraw(object);

% OBJECTDRAW Draws a object.
% 
% object = objectdraw(object);

for i = 1:length(object)
  object(i) = feval([object(i).type 'draw'], object(i));
end