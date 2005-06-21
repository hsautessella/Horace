function [s_out, e_out, n_out] = cut_data_arrays (iax, ilo, ihi, s, e, n)
% Sum signal, error and nbin arrays along the specified dimension between (and
% including) the two indexes. The output arrays are reduced in dimension by unity.
%
% Input arrays must have four or fewer dimensions. Checks are rudimentary - it is assumed
% that ilo and ihi are valid for the given summation axis, for example.

% Author:
%   T.G.Perring     21/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

ndims = length(size(s));

if ndims==1
    if iax==1
        s_out = squeeze(sum(s(ilo:ihi),1));
        e_out = squeeze(sum(e(ilo:ihi),1));
        n_out = squeeze(sum(n(ilo:ihi),1));
    else
        error ('ERROR: Invalid axis option')
    end
elseif ndims==2
    if iax==1
        s_out = squeeze(sum(s(ilo:ihi,:),1));
        e_out = squeeze(sum(e(ilo:ihi,:),1));
        n_out = squeeze(sum(n(ilo:ihi,:),1));
    elseif iax==2
        s_out = squeeze(sum(s(:,ilo:ihi),2));
        e_out = squeeze(sum(e(:,ilo:ihi),2));
        n_out = squeeze(sum(n(:,ilo:ihi),2));
    else
        error ('ERROR: Invalid axis option')
    end
elseif ndims==3
    if iax==1
        s_out = squeeze(sum(s(ilo:ihi,:,:),1));
        e_out = squeeze(sum(e(ilo:ihi,:,:),1));
        n_out = squeeze(sum(n(ilo:ihi,:,:),1));
    elseif iax==2
        s_out = squeeze(sum(s(:,ilo:ihi,:),2));
        e_out = squeeze(sum(e(:,ilo:ihi,:),2));
        n_out = squeeze(sum(n(:,ilo:ihi,:),2));
    elseif iax==3
        s_out = squeeze(sum(s(:,:,ilo:ihi),3));
        e_out = squeeze(sum(e(:,:,ilo:ihi),3));
        n_out = squeeze(sum(n(:,:,ilo:ihi),3));
    else
        error ('ERROR: Invalid axis option')
    end
elseif ndims==4
    if iax==1
        s_out = squeeze(sum(s(ilo:ihi,:,:,:),1));
        e_out = squeeze(sum(e(ilo:ihi,:,:,:),1));
        n_out = squeeze(sum(n(ilo:ihi,:,:,:),1));
    elseif iax==2
        s_out = squeeze(sum(s(:,ilo:ihi,:,:),2));
        e_out = squeeze(sum(e(:,ilo:ihi,:,:),2));
        n_out = squeeze(sum(n(:,ilo:ihi,:,:),2));
    elseif iax==3
        s_out = squeeze(sum(s(:,:,ilo:ihi,:),3));
        e_out = squeeze(sum(e(:,:,ilo:ihi,:),3));
        n_out = squeeze(sum(n(:,:,ilo:ihi,:),3));
    elseif iax==4
        s_out = squeeze(sum(s(:,:,:,ilo:ihi),4));
        e_out = squeeze(sum(e(:,:,:,ilo:ihi),4));
        n_out = squeeze(sum(n(:,:,:,ilo:ihi),4));
    else
        error ('ERROR: Invalid axis option')
    end
else
    error('ERROR: Number of dimensions of input arrays must be =< 4')
end