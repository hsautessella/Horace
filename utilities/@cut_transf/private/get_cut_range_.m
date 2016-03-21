function range = get_cut_range_(obj)
% Retrieve full cut range in the form of cellarray,
%
% $Revision$ ($Date$)
%

range = cell(1,4);
range{1} = obj.qh_range;
range{2} = obj.qk_range;
range{3} = obj.ql_range;
range{4} = obj.de_range;