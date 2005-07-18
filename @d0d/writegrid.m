function writegrid (w, binfil)
% Writes 0D dataset to a binary file.
%
% Syntax:
%   >> writegrid (data, binfil)
%
% Input:
% ------
%   w       0D Dataset
%   binfil  Name of file to whicht he data will be written.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

writegrid(get(w),binfil)