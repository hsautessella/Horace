function obj = check_and_set_transf_(obj,new_transf)
% Function checks if symmetry transformation is well defined and sets this
% transformation as new symmetry transformation.
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%


if size(new_transf) ~= [3,3]
    error('CUT_TRANSF:invalid_argument',...
        'symmetry transformation has to be a 3x3 matrix, in fact it is: [%d,%d]',...
        size(new_transf));
end

d = det(new_transf);
if abs(abs(d)-1)>1.e-6
    error('CUT_TRANSF:invalid_argument',...
        'Symmetry transformation determinant has to be equal to 1 but it is equal to: %f',d);
end

obj.transf_matrix_ = new_transf;


