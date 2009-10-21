function h=head_dnd(varargin)
% Display a summary of a file containing sqw information
% 
%   >> head_dnd           % prompts for file
%   >> head_dnd (file)
%
% To return header information in a structure
%   >> h = head_dnd
%   >> h = head_dnd (file)
%
%
% Gives the same information as display for an sqw object

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Get filename
if nargin==1 && ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1    % is a single row of characters
    noffset=1;
    if (exist(varargin{1},'file')==2)
        file_internal = varargin{1};
    else
        file_internal = getfile(varargin{1});
    end
elseif nargin==0
    noffset=0;
    file_internal = getfile('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
else
    error ('Input must be a file name')
end

% Make object
if nargout==0
    function_dnd(file_internal,@head,varargin{1+noffset:end});
else
    h = function_dnd(file_internal,@head,varargin{1+noffset:end});
end
