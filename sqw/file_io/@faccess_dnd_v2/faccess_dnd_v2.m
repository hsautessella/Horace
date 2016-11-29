classdef faccess_dnd_v2 < dnd_binfile_common
    % Class to access Horace dnd files written by Horace v1-v2
    %
	% Usage:
	%1) 
    %>>dnd_access = faccess_dnd_v2(filename) 
	% or
	% 2) 
	%>>dnd_access = faccess_dnd_v2(sqw_dnd_object,filename)
    %
	% 1) 
	% First form initializes accessor to existing dnd file where 
	% @param filename  :: the name of existing dnd file.
	%
	% Throws if file with filename is missing or is not written in dnd v1-v2 format.
	%
    % To avoid attempts to initialize this accessor using incorrect sqw file, 
	% access to existing sqw files should be organized using sqw format factory 
	% namely:
	%
    % >> accessor = sqw_formats_factory.instance().get_loader(filename)
	%
	% If the sqw file with filename is dnd v1 or v2 sqw file, the sqw format factory will 
	% return instance of this class, initialized for reading this file.
	% The initialized object allows to use all get/read methods described by dnd_file_interface.
    %
	% 2) 
	% Second form used to initialize the operation of writing new or updating existing dnd file.
	% where:
	%@param sqw_dnd_object:: existing fully initialized sqw or dnd object in memory. 
	%@param filename      :: the name of a new or existing dnd object on disc
	%
	% Update mode is initialized if the file with name filename exists and can be updated,
	% i.e. has the same number of dimensions, binning and  axis. In this case you can modify 
	% dnd methadata. 
	% if existing file can not be updated, it will be open in write mode. 
	% If file with filename does not exist, the object will be open in write mode.
	%
	% Initialized faccess_dnd_v2 object allows to use write/update methods of dnd_format_interface
	% and all read methods if the proper information already exists in the file. 
	%
	% Note:
    % The current sqw file format comes in two variants:
    %   - Horace version 1 and version 2: file format '-v2'
    %   (Autumn 2008 onwards). Does not contain instrument and sample fields in the header block.
    %
    % $Revision$ ($Date$)
    %
    %
    properties(Access = protected)
    end
    properties(Dependent)
    end
    
    methods
        function obj=faccess_dnd_v2(varargin)
            % constructor, to build sqw reader/writer version 2
            %
            % Usage:
            % ld = faccess_dnd_v2() % initialize empty sqw reader/writer version 2
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_dnd_v2(filename) % initialize sqw reader/writer  version 2
            %                       to load sqw file version 2.
            %                       Throw error if the file version is not sqw
            %                       version 2.
            % ld = faccess_dnd_v2(dnd_object) % initialize sqw reader/writer version 2
            %                       to save dnd object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            %
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %
        function [should,objinit,mess]= should_load_stream(obj,stream,fid)
            % Check if this loader should load input data
            % Currently should any dnd object
            %Usage:
            %
            %>> [should,obj_init,mess] = obj.should_load_stream(datastream,fid)
            % where
            % datastream:  structure returned by get_file_header function
            % Returns:
            % true if the loader can load these data, or false if not
            % with message explaining the reason for not loading the data
            % of should, object is initiated by appropriate file identified
            mess = '';
            if isstruct(stream) && all(isfield(stream,{'sqw_type','version'}))
                if ~stream.sqw_type
                    objinit = obj_init(fid,double(stream.num_dim));
                    should = true;
                else
                    should = false;
                    mess = ['not Horace dnd  ',obj.file_version,' file'];
                    objinit  =obj_init();
                end
            else
                error('SQW_FILE_IO:invalid_argument',...
                    'FACCESS_DND_V2::should_load_stream: the input structure for this function does not have correct format');
            end
        end
        %
        %
    end
    
end
