classdef sqw_binfile_common < sqw_file_interface
    % Class contains common logic and code used to access binary sqw files
    %
    %  Binary sqw-file accessors inherit this class, use common method,
    %  defined in this class implement remaining abstract methods,
    %  inherited from sqw_file_interface and overload the methods, which
    %  have different data access requests
    %
    %
    %
    % $Revision$ ($Date$)
    %
    
    properties(Access=protected)
        % position (in bytes from start of the file of the appropriate part
        % of Horace data information and the size of this part.
        % 0 means unknown/uninitialized or missing.
        main_header_pos_=26;
        main_head_pos_info_ =[];
        header_pos_=0;
        header_pos_info_ =[];
        detpar_pos_=0;
        detpar_pos_info_ =[];
        urange_pos_ = 0;
        pix_pos_=0;
        eof_pix_pos_=0;
        %
    end
    %
    methods(Access = protected)
        function obj=init_from_sqw_obj(obj,varargin)
            % intialize the structure of sqw file using sqw object as input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            if nargin < 2
                error('SQW_BINFILE_COMMON:runtime_error',...
                    'init_from_sqw_obj method should be ivoked with at least an existing sqw object provided');
            end
            if ~isa(varargin{1},'sqw')
                error('SQW_BINFILE_COMMON:invalid_argument',...
                    'init_from_sqw_obj method should be initiated by an sqw object');
            end
            %
            obj = init_headers_from_sqw_(obj,varargin{1});
            % initialize data fields
            % assume max data type which will be reduced if some fields are
            % missing (how they when initalized from sqw?)
            obj.data_type_ = 'a'; 
            obj = init_from_sqw_obj@dnd_binfile_common(obj,varargin{:});
            
            obj.sqw_holder_ = varargin{1};
            pix_info_pos = obj.data_fields_locations_;
            obj.urange_pos_  = pix_info_pos.urange_pos_;
            obj.pix_pos_     = pix_info_pos.pix_pos_+8; % serializer calculates pix position 
            % at the position of the npix as it is part of the pix field.
            % As we do not serialize pixels, here we adjust this value to
            % start of the real pix array.
            obj.eof_pix_pos_ = pix_info_pos.eof_pix_pos_;
            obj.npixels_ = size(obj.sqw_holder_.data.pix,2);

            
            %obj = init_pix_info_(obj);
        end
        %
        function obj=init_from_sqw_file(obj,varargin)
            % intialize the structure of faccess class using sqw file as input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            obj= init_sqw_structure_field_by_field_(obj);
        end
    end
    
    methods % defined by this class
        % get main sqw header
        main_header = get_main_header(obj,varargin);
        % get header of one of contributed files
        [header,pos]   = get_header(obj,varargin);
        % Read the detector parameters from propertly initialized binary file.
        det = get_detpar(obj);
        % read main sqw data  from propertly initialized binary file.
        [sqw_data,obj] = get_data(obj,varargin);
        % read pixels information
        pix    = get_pix(obj,varargin);
        % retrieve the whole sqw object from properly initialized sqw file
        sqw_obj = get_sqw(obj,varargin);
        % save or replace main file header
        obj = put_main_header(obj,varargin);
        %
        % Save new or fully overwrite existing sqw file
        obj = put_sqw(obj,varargin);
        
        %
        function [inst,obj] = get_instrument(obj,varargin)
            % get instrument, stored in a file. If no instrument is
            % defined, return empty structure.
            inst = struct();
        end
        %
        function [samp,obj] = get_sample(obj,varargin)
            % get sample, stored in a file. If no sample is defined, return
            % empty structure.
            samp = struct();
        end
        
        %
        function header = get_main_header_form(obj,varargin)
            % Return the structure of the main header in the form it
            % is written on hdd.
            % Usage:
            % header = obj.get_main_header_form();
            % header = obj.get_main_header_form('-const');
            %
            % Fields in file are:
            % --------------------------
            %   main_header.filename   Name of sqw file that is being read, excluding path
            %   main_header.filepath   Path to sqw file that is being read, including terminating file separator
            %   main_header.title      Title of sqw data structure
            %   main_header.nfiles     Number of spe files that contribute
            %
            % The value of the fields define the number of dimensions of
            % the data except strings, which defined by the string length
            header = get_main_header_form_(varargin{:});
        end
        %
        function header = get_header_form(obj,varargin)
            % Return structure of the contributing file header in the form
            % it is written on hdd.
            %
            % Fields in file are:
            % --------------------------
            %   header.filename     Name of sqw file excluding path
            %   header.filepath     Path to sqw file including terminating file separator
            %   header.efix         Fixed energy (ei or ef depending on emode)
            %   header.emode        Emode=1 direct geometry, =2 indirect geometry
            %   header.alatt        Lattice parameters (Angstroms)
            %   header.angdeg       Lattice angles (deg)
            %   header.cu           First vector defining scattering plane (r.l.u.)
            %   header.cv           Second vector defining scattering plane (r.l.u.)
            %   header.psi          Orientation angle (deg)
            %   header.omega        --|
            %   header.dpsi           |  Crystal misorientation description (deg)
            %   header.gl             |  (See notes elsewhere e.g. Tobyfit manual
            %   header.gs           --|
            %   header.en           Energy bin boundaries (meV) [column vector]
            %   header.uoffset      Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
            %   header.u_to_rlu     Matrix (4x4) of projection axes in hkle representation
            %                        u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
            %   header.ulen         Length of projection axes vectors in Ang^-1 or meV [row vector]
            %   header.ulabel       Labels of the projection axes [1x4 cell array of character strings]
            %
            % The following fields two fields are part of the header, but this function just fills them with the 'empty' default:
            %   header.instrument   Instrument description (scalar structure or object)
            %                      Set to default value struct (1x1 structure with no fields)
            %   header.sample       Sample description (scalar structure or object)
            %                      Set to default value struct (1x1 structure with no fields)
            % The value of the fields define the number of dimensions of
            % the data except strings, which defined by the string length
            header = struct('filename','','filepath','',...
                'efix',single(1),'emode',int32(1),...
                'alatt',single([1,3]),'angdeg',single([1,3]),...
                'cu',single([1,3]),'cv',single([1,3]),...
                'psi',single(1),'omega',single(1),'dpsi',single(1),...
                'gl',single(1),'gs',single(1),...
                'en',field_var_array(1),'uoffset',single([4,1]),...
                'u_to_rlu',single([4,4]),'ulen',single([1,4]),...
                'ulabel',field_cellarray_of_strings());
        end
        %
        function detpar_form = get_detpar_form(obj,varargin)
            % Return structure of the contributing file header in the form
            % it is written on hdd.
            %
            % Fields in the structure are:
            %
            % --------------------------
            %   det.filename    Name of file excluding path
            %   det.filepath    Path to file including terminating file separator
            %   det.group       Row vector of detector group number
            %   det.x2          Row vector of secondary flightpath (m)
            %   det.phi         Row vector of scattering angles (deg)
            %   det.azim        Row vector of azimuthal angles (deg)
            %                  (West bank=0 deg, North bank=90 deg etc.)
            %   det.width       Row vector of detector widths (m)
            %   det.height      Row vector of detector heights (m)
            %
            % one field of the file 'ndet' is written to the file but not
            % present in the structure, so has format: field_not_in_structure
            % group,x2,phi,azim,width and height array sizes are defined by
            % this structure size
            detpar_form = struct('filename','','filepath','',...
                'ndet',field_not_in_structure('group'),...
                'group',field_const_array_dependent('ndet'),...
                'x2',field_const_array_dependent('ndet'),...
                'phi',field_const_array_dependent('ndet'),...
                'azim',field_const_array_dependent('ndet'),...
                'width',field_const_array_dependent('ndet'),...
                'height',field_const_array_dependent('ndet'));
        end
        
        %
        function data_form = get_data_form(obj,varargin)
            % Return the structure of the data file header in the form
            % it is written on hdd.
            % Fields in the structure are:
            %
            
            % ------------------------------
            %   data.filename   Name of sqw file that is being read, excluding path
            %   data.filepath   Path to sqw file that is being read, including terminating file separator
            %          [Note that the filename and filepath that are written to file are ignored; we fill with the
            %           values corresponding to the file that is being read.]
            %
            %   data.title      Title of sqw data structure
            %   data.alatt      Lattice parameters for data field (Ang^-1)
            %   data.angdeg     Lattice angles for data field (degrees)
            %   data.uoffset    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
            %   data.u_to_rlu   Matrix (4x4) of projection axes in hkle representation
            %                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
            %   data.ulen       Length of projection axes vectors in Ang^-1 or meV [row vector]
            %   data.ulabel     Labels of the projection axes [1x4 cell array of character strings]
            %   data.iax        Index of integration axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
            %   data.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
            %                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
            %   data.pax        Index of plot axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
            %                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
            %   data.p          Cell array containing bin boundaries along the plot axes [column vectors]
            %                       i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
            %   data.dax        Index into data.pax of the axes for display purposes. For example we may have
            %                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
            %                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
            %                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
            %                  be reordered [row vector]
            %   data.s          Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.e          Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.npix       No. contributing pixels to each bin of the plot axes.
            %                  [size(data.pix)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.urange     True range of the data along each axis [urange(2,4)]
            %   data.pix        Array containing data for eaxh pixel:
            %                  If npixtot=sum(npix), then pix(9,npixtot) contains:
            %                   u1      -|
            %                   u2       |  Coordinates of pixel in the projection axes
            %                   u3       |
            %                   u4      -|
            %                   irun        Run index in the header block from which pixel came
            %                   idet        Detector group number in the detector listing for the pixel
            %                   ien         Energy bin number for the pixel in the array in the (irun)th header
            %                   signal      Signal array
            %                   err         Error array (variance i.e. error bar squared)
            %
            [ok,mess,pix_only,nopix,head,~] = parse_char_options(varargin,{'-pix_only','-nopix','-header'});
            if ~ok
                error('SQW_BINFILE_COMMON:invalid_argument',mess);
            end
            
            if pix_only
                data_form = struct('urange',single([2,4]),...
                    'dummy',field_not_in_structure('urange'),...
                    'pix',field_pix());
            else
                data_form = get_data_form@dnd_binfile_common(obj,varargin{:});
                if nopix || head
                    return
                end
                data_form.urange = single([2,4]);
                data_form.dummy = field_not_in_structure('pax');
                data_form.pix = field_pix();
            end
            
            % full header necessary to inentify datatype in the file
            if strncmp(obj.data_type,'un',2)
                return;
            end
            %
            if obj.data_type == 'a-' % data do not contain pixels
                data_form = rmfield(data_form,{'dummy','pix'});
                return;
            end
            %
        end
    end
    
end

