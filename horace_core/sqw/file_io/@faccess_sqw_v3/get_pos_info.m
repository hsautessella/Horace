function   pos_info = get_pos_info(obj)
% Return structure, containing position of every data field in the
% file (when object is initialized) plus some auxiliary information
% used to fully describe this file.
%
% Located in SQW_v3 due to a Matlab bug in inheritance chain
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)
%

fields2save = obj.fields_to_save();
pos_info  = struct();
for i=1:numel(fields2save)
    fld = fields2save{i};
    pos_info.(fld) = obj.(fld);
end


