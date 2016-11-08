function [ok,mess] = check_equal_size(obj,other_obj)
% check if other map describes the same size as the one
% from another object.
% Usage:
% [ok,mess] = obj.check_equal_size(other_obj)
% where:
% obj      -- the const_block_size object the base for comparison
% other_obj-- another const_block_size to compare with
% Returns:
% ok       -- true if sizes are equal, false, otherwise
% mess     -- empty if true, if false idientifies first different 
%             block in both maps 
%
%
% if upgrade map for other_obj is shorter than obj, its assumed that sizes are equal, if
% longer, then not.
%
% $Revision$ ($Date$)
%

bs1 = obj.get_must_fit();
bs2 = other_obj.get_must_fit();
mess = [];
keys = bs2.keys();
for i=1:numel(keys)
    theKey = keys{i};
    if bs1.isKey(theKey)
        bl1= bs1(theKey);
    else
        ok = false;
        mess = sprintf(' Base object does not have block names: %s',...
            theKey);
        return
        
    end
    bl2 = bs2(theKey);
    if numel(bl1) == numel(bl2)
        for j=1:size(bl1,2)
            if bl1(2,j) ~= bl2(2,j)
                ok = false;
                mess = sprintf(' The sizes of the block name: %s, element N%d/of%d are different',...
                    theKey,j,numel(bl1));
                return
            end
        end
    else
        ok=false;
        return
    end
end
ok = true;
