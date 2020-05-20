function varargout=set_efix_horace(varargin)
% Set the fixed neutron energy for an array of sqw objects.
%
%   >> set_efix(file, efix)
%   >> set_efix(file, efix, emode)
%
% Input:
% ------
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%   efix        Value or array of values of efix. If an array, all sqw
%              objects must have the same number of contributing spe data sets
%   emode       [Optional] Energy mode: 1=direct inelastic, 2=indirect inelastic, 0=elastic


% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)

if nargin<1 || nargin>3
    error('Check number of input arguments')
elseif nargout>0
    error('No output arguments returned by this function')
end

[varargout,mess] = horace_function_call_method (nargout, @set_efix, '$hor', varargin{:});
if ~isempty(mess), error(mess), end

