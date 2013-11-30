function val=horace_info_level(val_in)
% Set or retrieve level of information to be output by Horace routines
%
%   >> horace_info_level (ival)     % set level to ival
%   >> ival = horace_info_level;    % retrive information level
%
%   ival    Integer:
%              -1   No information messages to be printed
%               0   Major information messages to be printed
%               1   Minor information messages to be printed in addition
%                       :
%           The larger the value, the more information is printed
%
%
% Deprecated function:
%   Please set or get the information level directly from the Horace configuration
%       >> set(hor_config,'horace_info_level',ival)
%       >> ival = get(hor_config,'horace_info_level')


disp('*** Deprecated function: horace_info_level ***')
disp('*** Please set or get the information level directly from the Horace configuration:')
disp('       >> set(hor_config,''horace_info_level'',ival)')
disp('       >> ival = get(hor_config,''horace_info_level'')')

if nargin>0
    if isscalar(val_in) && isnumeric(val_in) && ~isnan(val_in)
        set(hor_config,'horace_info_level',val_in);
    else
        warning('HORACE:horace_info_level','Information level from Horace must be numeric and not NaN. Level left unchanged')
    end
end

if nargout>0
    val = get(hor_config,'horace_info_level');
end
