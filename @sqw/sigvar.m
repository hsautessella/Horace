function wout = sigvar (w)
% Create sigvar object from sqw object
% 
%   >> wout = sigvar (w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

if is_sqw_type(w)
    wout = sigvar(w.data.s, w.data.e);
else
    wout = sigvar(w.s, w.e);
end
