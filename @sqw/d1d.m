function wout = d1d (win)
% Convert input 1-dimensional sqw object into corresponding d1d object
%
%   >> wout = d1d (win)

% Special case of dnd included for completeness

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


ndim_req=1;     % required dimensionality

% The code below is identical for all dnd type converter routines
for i=1:numel(win)
    if dimensions(win(i))~=ndim_req
        if numel(win)==1
            error('sqw object is not two dimensional')
        else
            error('Not all elements in the array of sqw objects are two dimensional')
        end
    end
end

wout=dnd(win);  % calls sqw method for generic dnd conversion
