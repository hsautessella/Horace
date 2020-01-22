function [rez,n_errors,minVer,maxVer,compilation_date,can_use_mex_4_combine]=check_horace_mex()
% function checks if horace mex files are compiled correctly and return
% their SVN min and max version and the latest date these files were
% compiled
%
% Usage:
%>>[rez,n_errors]=check_horace_mex();
%>>[rez,n_errors,minVer,maxVer,compilation_date]=check_horace_mex()
%
% if input argument is present, the function also returns min and max svn
% versions of the mex files and the most recent compilation date of these
% files if n_errors = 0.
%
% If some mex files are can not be launched,the function returns the number of
% files not launched as n_errors. mex-files versions strings become empty.
%
% rez is cellarray, which contains reply from mex files queried about their
% version
%
%
% $Revision: 1738 $    $Date: 2019-03-12 14:31:09 +0000 (Tue, 12 Mar 2019) $
%

compilation_date  =[];

% list of the function names used in nice formatted messages formed by the
% function
functions_name_list={'accumulate_cut_c  : ','bin_pixels_c      : ',...
    'calc_projections  : ','sort_pixels_by_bin: ','recompute_bin_data: ',...                                                   
    'combine_sqw       : ','mtimesx_mex       : ','hdf_mex_reader    : '};
combine_num = numel(functions_name_list)-2; % provide special treatment for combine_sqw function
hdf_reader_num  = numel(functions_name_list);  % provide special treatment for hdf_mex_reader
% its expected to be last function of the pack

% list of the mex files handles used by Horace and verified by this script.
functions_handle_list={@accumulate_cut_c,@bin_pixels_c,...
    @calc_projections_c,@sort_pixels_by_bins,@recompute_bin_data_c,...
    @combine_sqw,@mtimesx_mex,@hdf_mex_reader};
rez = cell(numel(functions_name_list),1);

n_errors=0;
can_use_mex_4_combine = true;
can_use_mex_4_hdf = true;
for i=1:numel(functions_name_list)
    try
        rez{i}=[functions_name_list{i},functions_handle_list{i}()];
    catch Err
        rez{i}=[' Error in ',functions_name_list{i},Err.message];
        if strcmpi(functions_name_list{combine_num},functions_name_list{i})
            can_use_mex_4_combine=false;
        elseif strcmpi(functions_name_list{hdf_reader_num},functions_name_list{i})
             can_use_mex_4_hdf = false;
        else
            n_errors=n_errors+1;
        end
    end
end
% calculate minumal and maximal versions of mex files; if there are errors
% in deploying mex-files, the versions become undefined;
if ~(can_use_mex_4_combine && can_use_mex_4_hdf)
    select_rez = true(1,numel(functions_handle_list));
    if ~can_use_mex_4_combine; select_rez(combine_num) = false; end
    if ~can_use_mex_4_hdf; select_rez(hdf_reader_num) = false; end
    
    ver_rez = rez(select_rez);
else    
    ver_rez = rez;
end
minVer = 1e+32;
maxVer = -1;
if nargout>2 && n_errors==0
    n_mex=numel(ver_rez);
    
    for i=1:n_mex
        ver_str=ver_rez{i};
        ind = regexp(ver_str,':');
        ver_s=ver_str(ind(3)+1:ind(3)+5);
        ver=sscanf(ver_s,'%d');
        if ver>maxVer
            maxVer=ver;
            al=regexp(ver_str,'\(','split');
            compilation_date  = al{2};
        end
        if ver<minVer;       minVer=ver;
        end
    end
else
    minVer=[];
    maxVer=[];
end

