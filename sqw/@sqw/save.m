function save (w, file)
% Save a sqw object or array of sqw objects to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%
% Input:
%   w       sqw object
%   file    [optional] File for output. if none given, then prompted for a file
%   
%   Note that if w is an array of sqw objects then file must be a cell
%   array of filenames of the same size.
%
% Output:

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Get file name - prompting if necessary
if nargin==1 
    file_internal = putfile('*.sqw');
    if (isempty(file_internal))
        error ('No file given')
    end
else
    [file_internal,mess]=putfile_horace(file);
    if ~isempty(mess)
        error(mess)
    end
end
if ~iscellstr(file_internal)
    file_internal=cellstr(file_internal);
end
if numel(file_internal)~=numel(w)
    error('Number of data objects in array does not match number of file names')
end

horace_info_level = ...
    config_store.instance().get_value('hor_config','log_level');

ldw = sqw_formats_factory.instance().get_pref_access();
for i=1:numel(w)
    % Write data to file   x
    if horace_info_level>-1
        disp(['Writing to ',file_internal{i},'...'])
    end
    ldw = ldw.init(w(i),file_internal{i});
    ldw = ldw.put_sqw();
    ldw = ldw.delete();
end
