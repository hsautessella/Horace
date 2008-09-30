function wout = section (win, varargin)
% Takes a section out of a 1-dimensional dataset.
%
% Syntax:
%   >> wout = section (win, [ax_1_lo, ax_1_hi])
%
% Input:
% ------
%   win                 3-dimensional dataset.
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits. Bins are retained whose
%                      centres lie in this range.
%                       To retain the limits of the input structure, type '', [], or the scalar '0'
%
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example:
%   >> wout = section (win, [1.9, 2.1])
%                                                           

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargin==1
    wout = win; % trivial case of no sectioning being required
else
    wout = dnd(section(sqw(win),varargin{:}));
end
