classdef iVirt_field< sqw_field_format_interface
    %  The class describes interface for the format helpers, 
    %  which are not present in sqw structure, but used during save/restore
    %  to help indentify properties of other fields
    %
    %  As the value of this type of field is used by other fields, these 
    %  fields have method to store their value
    %
    % $Revision$ ($Date$)
    %
    
    properties(Access=protected)
        field_val_=[];
    end
    
    properties(Dependent)
        field_value;        
    end
    methods
        function val = get.field_value(obj)
            val = obj.field_val_;
        end
        function obj = set.field_value(obj,val)
            obj.field_val_ = val;
        end
        
    end
   
  
end

