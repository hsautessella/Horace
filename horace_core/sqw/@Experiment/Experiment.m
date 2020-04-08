classdef Experiment
    %EXPERIMENT Container object for all data describing the Experiment
    
    properties(Access=private)
        class_version_ = 1;
        instruments_ = []
        detector_array_ = []
        sample_ = []
    end
    
    properties (Dependent)
        % Mirrors of private properties
        instruments
        detector_array
        sample
    end
    
    methods
        function obj = Experiment(varargin)
            % Create a new Experiment object.
            %
            %   obj = Experiment()
            %   obj = Experiment(detector_array[s], instrument[s], sample[s])
            %
            % Required:
            %   detector_array  Detector array (IX_detector_array objects)
            %   instrument      Instrument (Concrete class inheriting IX_inst)
            %   sample          Sample data (IX_sample object)
            %
            % Each argument can be a single object or array of objects.
            if nargin == 0
                return;
            end

            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_fermi_chopper.loadobj(varargin{1});
            elseif nargin==3
                obj.detector_array = varargin{1};
                obj.instruments =  varargin{2};
                obj.sample = varargin{3};
            else
                error ('Must give all of detector_array, instrument and sample')
            end
        end

        function obj=set.detector_array_(obj,val)
            if isa(val,'IX_detector_array') || isempty(val)
                obj.detector_array_ = val;
            else
                error('Detector array must be one or an array of IX_detector_array object')
            end
        end
        
        function obj=set.instruments_(obj,val)
            if isa(val,'IX_inst') || isempty(val)
                obj.instruments_ = val;
            else
                error('Instruments must be one or an array of IX_inst objects')
            end
        end
        
        function obj=set.sample_(obj,val)
            if isa(val,'IX_sample') || isempty(val)
                obj.sample_ = val;
            else
                error('Sample must be one or an array of IX_sample objects')
            end
        end

        function val=get.detector_array(obj)
            val=obj.detector_array_;
        end
        function obj=set.detector_array(obj, val)
            obj.detector_array_ = val;
        end

        function val=get.instruments(obj)
            val=obj.instruments_;
        end
        function obj=set.instruments(obj, val)
            obj.instruments_ = val;
        end

        function val=get.sample(obj)
            val=obj.sample_;
        end
        function obj=set.sample(obj, val)
            obj.sample_ = val;
        end

        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            S = structIndep(obj);
        end
    end

    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class

            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
    end
    %======================================================================
end

