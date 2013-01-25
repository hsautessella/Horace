function varargout = head(varargin)
% Read header of a d1d object stored in a file, or objects in a set of files
% 
%   >> h=head(d1d,file)
%
% Gives the same information as display for a d1d object.
%
% Need to give first argument as an d1d object to enforce a call to this function.
% Can simply create a dummy object with a call to d1d:
%    e.g. >> head(d1d,'c:\temp\my_file.d1d')
%
% Input:
% -----
%   d1d         Dummy d1d object to enforce the execution of this method.
%               Can simply create a dummy object with a call to d1d:
%                   e.g. >> w = read(d1d,'c:\temp\my_file.d1d')
%
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each d1d object
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type


% If data source is a filename or data_source structure, then must ensure that matches dnd type
[data_source, args, source_is_file, sqw_type, ndims, source_arg_is_filename, mess] = parse_data_source (sqw(varargin{1}), varargin{2:end});
if ~isempty(mess)
    error(mess)
end
if source_is_file   % either file names or data_source structure as input
    if any(sqw_type) || any(ndims~=dimensions(varargin{1}(1)))     % must all be the required dnd type
        error(['Data file(s) not (all) ',classname,' type i.e. no pixel information'])
    end
end

% Now call sqw head routine
if nargout==0
    if source_is_file
        head(sqw,data_source,args{:});
    else
        head(sqw(data_source),args{:});
    end
else
    if source_is_file
        argout=head(sqw,data_source,args{:});
    else
        hout=head(sqw(data_source),args{:});
    end
end

% Package output: if file data source structure then package all output
% arguments as a single cell array, as the output will be unpacked by the
% control routine that called this method. If object data source or file
% name, then package as conventional varargout.

if nargout>0
    if source_arg_is_filename
        % Input data source to this function is filename(s), but sqw method
        % was passed a data_source structure. Therefeore must unpack arguments
        varargout=argout;   % generic, regardless of number of arguments packed in argout
    else
        if ~source_is_file
            
        else
            % source is 
            varargout{1}=argout;
        end
    end
end
