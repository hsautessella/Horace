function da(win,varargin)
% Area plot for 2D dataset
%
%   >> da(win)
%   >> da(win,xlo,xhi);
%   >> da(win,xlo,xhi,ylo,yhi);
% Or:
%   >> da(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'colormap','bone');
%
% See help for libisis\da for more details of other options

% R.A. Ewings 14/10/2008

da(sqw(win),varargin{:});
