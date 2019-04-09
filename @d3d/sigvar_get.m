function [s,var,mask_null] = sigvar_get (w)
% Get signal and variance from object, and a logical array of which values to ignore
% 
%   >> [s,var,mask_null] = sigvar_get (w)

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)

s = w.s;
var = w.e;
mask_null = logical(w.npix);
