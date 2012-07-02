function [data, mess] = get_sqw_main_header (fid, opt)
% Read the main header block for the results of performing calculate projections on spe file(s).
%
% Syntax:
%   >> [data, mess] = get_sqw_main_header(fid, data_in)
%
% The default behaviour is that the filename and filepath that are written to file are ignored; 
% we fill with the values corresponding to the file that is being read.
% This can be cahnged with teh '-hverbatim' option (below)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   opt         Optional flag
%                   '-hverbatim'   The file name as stored in the main_header and
%                                  data sections are returned as stored, not constructed from the
%                                  value of fopen(fid). This is needed in some applications where
%                                  data is written back to the file with a few altered fields.
% Output:
% -------
%   data        Structure containing fields read from file (details below)
%   mess        Error message; blank if no errors, non-blank otherwise
%
% Fields read from file are:
%   data.filename   Name of sqw file that is being read, excluding path
%   data.filepath   Path to sqw file that is being read, including terminating file separator
%   data.title      Title of sqw data structure
%   data.nfiles     Number of spe files that contribute

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

data=[];
mess='';

hverbatim=false;
if exist('opt','var')
    if ischar(opt) && strcmpi(opt,'-hverbatim')
        hverbatim=true;
    else
        mess = 'invalid option';
        return
    end
end

% Read data from file:
try
    n = fread_catch(fid,1,'int32');
    dummy_filename = fread(fid,[1,n],'*char');

    n = fread_catch(fid,1,'int32');
    dummy_filepath = fread(fid,[1,n],'*char');

    if hverbatim
        % Read filename and path from file
        data.filename=dummy_filename;
        data.filepath=dummy_filepath;
    else
        % Get file name and path (incl. final separator)
        [path,name,ext]=fileparts(fopen(fid));
        data.filename=[name,ext];
        data.filepath=[path,filesep];
    end
    
    n = fread_catch(fid,1,'int32');
    data.title = fread(fid,[1,n],'*char');

    data.nfiles = fread(fid,1,'int32');

catch
    mess='problems reading file';
end
