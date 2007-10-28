function objectdelete(object)

% OBJECTDELETE Clear up the graphics that portray an object.
%
% objectdelete(object)
%
% version 0.1 
% Copyright (c) Neil Lawrence 2002


for i = 1:length(object)
  try
    delete(object(i).handle)
  catch
  end
  try
    delete(object(i).controlPointHandle)
  catch
  end
end